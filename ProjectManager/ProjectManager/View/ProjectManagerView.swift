//
//  ProjectManagerView.swift
//  ProjectManager
//
//  Created by Judy on 2022/09/07.
//

import UIKit

final class ProjectManagerView: UIView {
    // MARK: - Properties
    private let toDoTitleView = HeaderView()
    private let doingTitleView = HeaderView()
    private let doneTitleView = HeaderView()
    
    private let toDoTableVeiw: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let doingTableVeiw: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let doneTableVeiw: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let toDoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    private let doingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    private let doneStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Methods
    private func addSubView() {
        toDoTitleView.configure(title: "TODO", count: 0)
        doingTitleView.configure(title: "DOING", count: 0)
        doneTitleView.configure(title: "DONE", count: 0)
        
        toDoStackView.addArrangedSubview(toDoTitleView)
        toDoStackView.addArrangedSubview(toDoTableVeiw)
        doingStackView.addArrangedSubview(doingTitleView)
        doingStackView.addArrangedSubview(doingTableVeiw)
        doneStackView.addArrangedSubview(doneTitleView)
        doneStackView.addArrangedSubview(doneTableVeiw)
        
        horizontalStackView.addArrangedSubview(toDoStackView)
        horizontalStackView.addArrangedSubview(doingStackView)
        horizontalStackView.addArrangedSubview(doneStackView)
        
        self.addSubview(horizontalStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            horizontalStackView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            horizontalStackView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            horizontalStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupView() {
        addSubView()
        setupConstraints()
        self.backgroundColor = .systemBackground
    }
}
