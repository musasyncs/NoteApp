//
//  NoteViewController.swift
//  Journal App
//
//  Created by Ewen on 2021/9/21.
//

import UIKit

class NoteViewController: UIViewController {
    
    var note: Note?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var horizontalStackView: UIStackView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private func setup() {
        [titleTextField, bodyTextView, saveButton, deleteButton].forEach{ $0?.layer.cornerRadius = 7 }
        
        bodyTextView.textContainerInset = UIEdgeInsets(top: 30, left: 15, bottom: 30, right: 15)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 19, height: 19))
        titleTextField.leftViewMode = .always
        titleTextField.leftView = leftView
        
        horizontalStackView.isLayoutMarginsRelativeArrangement = true
        horizontalStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15)
        
        setupNotification() //鍵盤出現與消失要調整bottomConstraint
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
            bottomConstraint.constant = keyboardFrame.height + 20
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide() {
        bottomConstraint.constant = 50
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        //在前一頁按新增按鈕，沒有傳 note 過來，要建立新 note
        if note == nil {
            let dic = [
                "docId": UUID().uuidString,
                "title": titleTextField.text ?? "",
                "body": bodyTextView.text ?? "",
                "isStarred": false,
                "createdAt": Date(),
                "lastUpdatedAt": Date()
            ] as [String : Any]
            let newNote = Note(dic: dic)
            note = newNote
        }
        //顯示note
        titleTextField.text = note!.title
        bodyTextView.text = note!.body
        setStarButtonImage(note!) //根據note的isStarred布林值決定星星有無填滿
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        note = nil
        titleTextField.text = ""
        bodyTextView.text = ""
    }
    
    
    //MARK: -  functions
    func setStarButtonImage(_ note: Note) {
        let imageName = note.isStarred ? "star.fill" : "star"
        starButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        note?.title = titleTextField.text ?? ""
        note?.body  = bodyTextView.text ?? ""
        note?.lastUpdatedAt = Date()
        //更新 document
        NotesManager().saveNote(note!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func starTapped(_ sender: Any) {
        note?.isStarred.toggle()
        setStarButtonImage(note!)
        //更新 document 的isStarred欄
        NotesManager().updateStarStatus(docId: note!.docId, isStarred: note!.isStarred)
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        //刪除 document
        NotesManager().deleteNote(note!)
        dismiss(animated: true, completion: nil)
    }
    
}
