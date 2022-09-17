//
//  ContentView.swift
//  TwoWayBinding
//
//  Created by Marco Carmona on 9/13/22.
//

import SwiftUI
import UIKit

class TodoItem: ObservableObject {
    let title: String
    @Published var completed: Bool
    
    init(_ title: String) {
        self.title = title
        self.completed = false
    }
}

struct TodoListCell: View {
    @ObservedObject var item: TodoItem
    
    var body: some View {
        HStack {
            Text(item.title)
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .strikethrough(item.completed)
                .foregroundColor(item.completed ? .gray : .black)
            
            Toggle("", isOn: $item.completed.animation())
                .frame(maxWidth: 50)
        }
    }
}

class TodoListViewController: UIViewController {
    var collectionView: UICollectionView!
    private var todoListCellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, TodoItem>!
    
    let todoItems = [
        TodoItem("Write a blog post"),
        TodoItem("Call John"),
        TodoItem("Make doctor's appointment"),
        TodoItem("Reply emails"),
        TodoItem("Buy Lego for Jimmy"),
        TodoItem("Get a hair cut"),
        TodoItem("Book flight to Japan"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create cell registration
        todoListCellRegistration = .init { cell, indexPath, item in
            
            // Supported from iOS 16
            cell.contentConfiguration = UIHostingConfiguration {
                TodoListCell(item: item)
            }
            
            var newBgConfiguration = UIBackgroundConfiguration.listGroupedCell()
            newBgConfiguration.backgroundColor = .systemBackground
            cell.backgroundConfiguration = newBgConfiguration
        }
        
        // Configure collection view using list layout
        let layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
        collectionView.dataSource = self
        
        view = collectionView
        
        // Add Complete All button
        // TODO: This is not being shown
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Complete All",
            style: .plain,
            target: self,
            action: #selector(completeAllTapped)
        )
    }
    
    @objc private func completeAllTapped() {
        for item in todoItems {
            item.completed = true
        }
    }
}

struct ContentView: View {
    var body: some View {
        UIViewControllerWrapper()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension TodoListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = todoItems[indexPath.row]
        let cell = collectionView.dequeueConfiguredReusableCell(
            using: todoListCellRegistration,
            for: indexPath,
            item: item
        )
        
        return cell
    }
    
}

struct UIViewControllerWrapper: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return TodoListViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
}
