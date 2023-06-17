//
//  FindViewController.swift
//  REC
//
//  Created by 박상준 on 2023/06/15.
//

import UIKit

struct MovieFind: Decodable {
    let title: String
    let id:String
    let overview : String
    let vote_average: Double
}

class FindViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var findText : String = ""
    var filteredMovies: [MovieFind] = []


    @IBOutlet weak var findTableView: UITableView!
    @IBOutlet weak var searchText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchText.text = findText
        findTableView.dataSource = self
        findTableView.delegate = self
        fetchAndFilterMovies()
    }
    //화면이동
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail" {
            guard let destinationVC = segue.destination as? DetailViewController,
                let indexPath = findTableView.indexPathForSelectedRow else {
                return
            }
            let movieFind = filteredMovies[indexPath.row]
            destinationVC.getTitle = movieFind.title
        }
    }
    //영화 정보 렌더링
    func fetchAndFilterMovies() {
        if let url = Bundle.main.url(forResource: "top100_movies", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let allMovies = try decoder.decode([MovieFind].self, from: data)
                filteredMovies = allMovies.filter { $0.title.contains(findText) }
                filteredMovies.sort { $0.vote_average > $1.vote_average }
                
                print("Movies loaded: \(filteredMovies.count)")
                print("Movies filter first : \(filteredMovies.endIndex)")
                findTableView.reloadData()
            } catch {
                print("Error: \(error)")
            }
        }
    }
    //테이블 관련 메소드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = findTableView.dequeueReusableCell(withIdentifier: "FindMovieCell", for: indexPath) as! FindMovieCell
        let movie = filteredMovies[indexPath.row]
        
        cell.titleLabel.text = movie.title
        cell.idLabel.text = "ID : \(movie.id)"
        cell.overview.text = movie.overview
        cell.posterImageView.image = UIImage(named: "poster")

        return cell
    }
    
}
