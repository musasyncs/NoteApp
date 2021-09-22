//
//  ViewController.swift
//  Journal App
//
//  Created by Ewen on 2021/9/21.
//

import UIKit

class ViewController: UIViewController {
    private var notes = [Note]()
    private var notesManager = NotesManager()
    private var isStarFiltered = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var starFilterButton: UIBarButtonItem!
     
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        notesManager.delegate = self
    }
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        //根據isStarFiltered布林值決定星星有無填滿
        setStarFilterButtonImage()
        
        //抓data
        isStarFiltered ? notesManager.getNotes(starredOnly: true) :  notesManager.getNotes()
    }

    //MARK: -  functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let noteVC = segue.destination as! NoteViewController
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        noteVC.note = notes[indexPath.section]
        tableView.deselectRow(at: indexPath, animated: true) //記得deselectRow!
    }
    
    func setStarFilterButtonImage() {
        let imageName = isStarFiltered ? "star.fill" : "star"
        starFilterButton.image = UIImage(systemName: imageName)
    }
    
    @IBAction func starFilterTapped(_ sender: Any) {
        //修改isStarFiltered成真或假
        isStarFiltered.toggle()
        
        //根據isStarFiltered布林值決定星星有無填滿
        setStarFilterButtonImage()
        
        //抓data
        isStarFiltered ? notesManager.getNotes(starredOnly: true) :  notesManager.getNotes()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        let titleLabel = cell.viewWithTag(1) as? UILabel
        titleLabel?.text = notes[indexPath.section].title
        let bodyLabel = cell.viewWithTag(2) as? UILabel
        bodyLabel?.text = notes[indexPath.section].body
        return cell
    }
}

extension ViewController: NotesManagerProtocol {
    func notesRetrieved(notes: [Note]) {
        self.notes = notes
        tableView.reloadData()
    }
}
