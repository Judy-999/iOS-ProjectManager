//
//  ProjectManager - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import RxSwift

final class ProjectManagerViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = WorkViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI
    private let todoTableView = WorkTableView(frame: .zero, style: .grouped)
    private let doingTableView = WorkTableView(frame: .zero, style: .grouped)
    private let doneTableView = WorkTableView(frame: .zero, style: .grouped)
    
    private let toDoTitleView = HeaderView()
    private let doingTitleView = HeaderView()
    private let doneTitleView = HeaderView()
    
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBinding()
    }
    
    // MARK: - UI setup
    private func setupView() {
        self.navigationItem.title = "Project Manager"
        self.view.backgroundColor = .systemGray6
        
        addSubView()
        setupConstraints()
        configureAddBarButton()
    }
    
    private func addSubView() {
        toDoTitleView.configure(title: "TODO", count: 0)
        doingTitleView.configure(title: "DOING", count: 0)
        doneTitleView.configure(title: "DONE", count: 0)
        
        todoTableView.tableHeaderView = toDoTitleView
        doingTableView.tableHeaderView = doingTitleView
        doneTableView.tableHeaderView = doneTitleView
        
        horizontalStackView.addArrangedSubview(todoTableView)
        horizontalStackView.addArrangedSubview(doingTableView)
        horizontalStackView.addArrangedSubview(doneTableView)
        
        self.view.addSubview(horizontalStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            horizontalStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            horizontalStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            horizontalStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureAddBarButton() {
        let addWorkBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                               style: .plain, target: self,
                                               action: #selector(addWorkBarButtonTapped))
        self.navigationItem.rightBarButtonItem = addWorkBarButton
    }
    
    @objc private func addWorkBarButtonTapped() {
        let manageViewController = ManageWorkViewController()
        manageViewController.configureAddMode(viewModel)
        let manageNavigationController = UINavigationController(rootViewController: manageViewController)
        self.present(manageNavigationController, animated: true)
    }
    
    // MARK: - UI Binding
    private func setupBinding() {
        bindWorkTableView()
        bindHeaderImage()
        setWorkSelection()
        setWorkDeletion()
    }
    
    private func bindWorkTableView() {
        let longGesture: (WorkState) -> UILongPressGestureRecognizer = { state in
            switch state {
            case .todo:
                return UILongPressGestureRecognizer(target: self, action: #selector(self.showTodoPopView))
            case .doing:
                return UILongPressGestureRecognizer(target: self, action: #selector(self.showDoingPopView))
            case .done:
                return UILongPressGestureRecognizer(target: self, action: #selector(self.showDonePopView))
            }
        }
        
        viewModel.works
            .map {
                $0.filter { $0.state == .todo }
            }.observe(on: MainScheduler.instance)
            .bind(to: todoTableView.rx.items(cellIdentifier: WorkTableViewCell.identifier,
                                             cellType: WorkTableViewCell.self)) { _, item, cell in
                cell.configure(with: item)
                cell.addGestureRecognizer(longGesture(item.state))
            }.disposed(by: disposeBag)
        
        viewModel.works
            .map {
                $0.filter { $0.state == .doing }
            }.observe(on: MainScheduler.instance)
            .bind(to: doingTableView.rx.items(cellIdentifier: WorkTableViewCell.identifier,
                                                                cellType: WorkTableViewCell.self)) { _, item, cell in
                cell.configure(with: item)
                cell.addGestureRecognizer(longGesture(item.state))
           }.disposed(by: disposeBag)
        
        viewModel.works
            .map {
                $0.filter { $0.state == .done }
            }.observe(on: MainScheduler.instance)
            .bind(to: doneTableView.rx.items(cellIdentifier: WorkTableViewCell.identifier,
                                             cellType: WorkTableViewCell.self)) { _, item, cell in
                cell.configure(with: item)
                cell.addGestureRecognizer(longGesture(item.state))
            }.disposed(by: disposeBag)
    }
    
    private func bindHeaderImage() {
        viewModel.works
            .map {
                $0.filter { $0.state == .todo }
            }.map {
                UIImage(systemName: "\($0.count).circle.fill")
            }.asDriver(onErrorJustReturn: nil)
            .drive(toDoTitleView.countImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.works
            .map {
                $0.filter { $0.state == .doing }
            }.map {
                UIImage(systemName: "\($0.count).circle.fill")
            }
            .asDriver(onErrorJustReturn: nil)
            .drive(doingTitleView.countImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.works
            .map {
                $0.filter { $0.state == .done }
            }.map {
                UIImage(systemName: "\($0.count).circle.fill")
            }
            .asDriver(onErrorJustReturn: nil)
            .drive(doneTitleView.countImageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    private func setWorkSelection() {
        todoTableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.showManageWorkView(self, work: self.viewModel.selectWork(by: index.row, .todo))
                self.todoTableView.deselectRow(at: index, animated: true)
            }).disposed(by: disposeBag)
        
        doingTableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.showManageWorkView(self, work: self.viewModel.selectWork(by: index.row, .doing))
                self.doingTableView.deselectRow(at: index, animated: true)
            }).disposed(by: disposeBag)
        
        doneTableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                
                self.showManageWorkView(self, work: self.viewModel.selectWork(by: index.row, .done))
                self.doneTableView.deselectRow(at: index, animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func setWorkDeletion() {
        todoTableView.rx.itemDeleted
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.viewModel.deleteWork(self.viewModel.selectWork(by: index.row, .todo))
            }).disposed(by: disposeBag)
        
        doingTableView.rx.itemDeleted
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.viewModel.deleteWork(self.viewModel.selectWork(by: index.row, .doing))
            }).disposed(by: disposeBag)
        
        doneTableView.rx.itemDeleted
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.viewModel.deleteWork(self.viewModel.selectWork(by: index.row, .done))
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Methods
    private func showManageWorkView(_ view: UIViewController, work: Work) {
        let manageViewController = ManageWorkViewController()
        manageViewController.configureEditMode(with: work, viewModel)
        let manageNavigationController = UINavigationController(rootViewController: manageViewController)
        view.present(manageNavigationController, animated: true)
    }
    
    @objc private func showTodoPopView(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: todoTableView)
        guard let index = todoTableView.indexPathForRow(at: point) else { return }
        
        showPopView(viewModel.selectWork(by: index.row, .todo), recognizer.view)
    }
    
    @objc private func showDoingPopView(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: doingTableView)
        guard let index = doingTableView.indexPathForRow(at: point) else { return }
        
        showPopView(viewModel.selectWork(by: index.row, .doing), recognizer.view)
    }
    
    @objc private func showDonePopView(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: doneTableView)
        guard let index = doneTableView.indexPathForRow(at: point) else { return }
        
        showPopView(viewModel.selectWork(by: index.row, .done), recognizer.view)
    }
    
    private func showPopView(_ work: Work, _ sourceView: UIView?) {
        let changeWorkStateViewController = ChangeWorkStateViewController()
        changeWorkStateViewController.setupView(for: work, viewModel)
        changeWorkStateViewController.modalPresentationStyle = .popover
        changeWorkStateViewController.preferredContentSize = CGSize(width: 250, height: 100)
        
        guard let popController = changeWorkStateViewController.popoverPresentationController else { return }
        popController.permittedArrowDirections = .up
        popController.sourceView = sourceView
        self.navigationController?.present(changeWorkStateViewController, animated: true)
    }
}
