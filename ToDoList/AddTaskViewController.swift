//
//  AddTaskViewController.swift
//  ToDoList
//
/*
 MIT License
 
 Copyright (c) 2018 Gwinyai Nyatsoka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var taskNameTextField: UITextField!
    
    @IBOutlet weak var taskDetailsTextView: UITextView!
    
    @IBOutlet weak var taskCompletionDatePicker: UIDatePicker!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // So we can dismiss keyboard by tapping anywhere on the screen.
    
    lazy var touchView: UIView = {
        
        let _touchView = UIView()
        
        _touchView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0)
        
        let touchViewTapped = UIGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        _touchView.addGestureRecognizer(touchViewTapped)
        
        _touchView.isUserInteractionEnabled = true
        
        _touchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        return _touchView
        
    }()
    
    // toolBarDone stands right above the keyboard.
    
    let toolBarDone = UIToolbar()
    
    var activeTextField: UITextField?
    
    var activeTextView: UITextView?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let navigationItem = UINavigationItem(title: "Add task")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidTouch))
        
        navigationBar.items = [navigationItem]
        
        taskDetailsTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        taskDetailsTextView.layer.borderWidth = CGFloat(0.25)
        
        taskDetailsTextView.layer.cornerRadius = CGFloat(3)
        
        // Toolbar to dismiss keyboard by tapping a button above it.
        
        toolBarDone.sizeToFit()
        
        toolBarDone.barTintColor = UIColor.red
        
        toolBarDone.isTranslucent = false
        
        let flexspace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        let barButtonDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTapped))
        
        barButtonDone.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        toolBarDone.items = [flexspace, barButtonDone, flexspace]
        
        // inputAccessoryView = additional, small view above the keyboard
        
        taskNameTextField.inputAccessoryView = toolBarDone
        
        taskDetailsTextView.inputAccessoryView = toolBarDone
        
        taskNameTextField.delegate = self
        
        taskDetailsTextView.delegate = self
        
    }
    
    // MARK: - Keyboard methods
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.registerFromKeyboardNotification()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        self.deregisterFromKeyboardNotification()
        
    }
    
    func registerFromKeyboardNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification: )), name: UIWindow.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasHidden(notification: )), name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    func deregisterFromKeyboardNotification() {
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    // MARK: - View adjustment methods relative to the keyboard and views
    
    @objc func keyboardWasShown(notification: NSNotification) {
        
        view.addSubview(touchView)
        
        // Some info about the keyword that includes its size info.
        
        let info: NSDictionary = notification.userInfo! as NSDictionary
        
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: (keyboardSize!.height + toolBarDone.frame.size.height + 10.0 ), right: 0)
        
        // contentInset = padding of the scroll view, scrollIndicatorInsets = padding of the scrollable part of the scroll view
        
        self.scrollView.contentInset = contentInsets
        
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        // aRect = view of the entire screen including everything on it
        
        var aRect: CGRect = UIScreen.main.bounds
        
        aRect.size.height -= keyboardSize!.height
        
        // To make sure that keyboard doesn't overlap the text field we're on.
        
        if activeTextField != nil {
            
            if (!aRect.contains(activeTextField!.frame.origin)) {
                
                self.scrollView.scrollRectToVisible(activeTextField!.frame, animated: true)
                
            }
            
        }
        
        else if activeTextView != nil {
            
            let textViewPoint: CGPoint = CGPoint(x: activeTextView!.frame.origin.x, y: activeTextView!.frame.height + activeTextView!.frame.height)
            
            if (aRect.contains(textViewPoint)) {
                
                self.scrollView.scrollRectToVisible(activeTextView!.frame, animated: true)
                
            }
            
        }
        
    }
    
    @objc func keyboardWasHidden(notification: NSNotification) {
        
        touchView.removeFromSuperview()
        
        self.scrollView.contentInset = UIEdgeInsets.zero
        
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        
        self.view.endEditing(true)
        
    }
    
    
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    
    // MARK: - Button methods
    
    @objc func doneButtonTapped() {
        
        view.endEditing(true)
        
    }
    
    @objc func cancelButtonDidTouch() {
        
        dismiss(animated: true)
        
    }
    
    @IBAction func addTaskDidTouch(_ sender: Any) {
        
        // Input verifications
        
        guard let taskName = taskNameTextField.text, !taskName.isEmpty else {
            
            reportError(title: "Invalid task name", message: "Task name is required")
            
            return
            
        }
        
        if taskDetailsTextView.text.isEmpty {
            
            reportError(title: "Task details are empty", message: "Please write inside")
            
            return
            
        }
        
        let taskDetails: String = taskDetailsTextView.text
        
        let completionDate: Date = taskCompletionDatePicker.date
        
        if completionDate < Date() {
            
            reportError(title: "Task date is in the past", message: "Please choose the right date ")
            
            return
            
        }
        
        let toDoItem = ToDoItem(name: taskName, details: taskDetails, completionDate: completionDate)
        
        NotificationCenter.default.post(name: NSNotification.Name.init("com.todoapp.addtask"), object: toDoItem)
        
        // Dismiss AddTaskViewController entirely if task specs completed successfully.
        
        dismiss(animated: true)
        
    }
    
    func reportError(title: String, message: String ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default) { action in
            
            alert.dismiss(animated: true)
            
        }
        
        alert.addAction(alertAction)
        
        present(alert, animated: true)
        
    }
    
}

// MARK: - Text extensions

extension AddTaskViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        activeTextView = textView
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        activeTextView = nil
        
    }
    
}

extension AddTaskViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeTextField = textField
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        activeTextField = nil
        
    }
    
}
