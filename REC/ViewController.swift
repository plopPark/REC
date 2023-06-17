//
//  ViewController.swift
//  REC
//
//  Created by 박상준 on 2023/06/15.
//

import UIKit
struct Movie: Decodable {
    let title: String
    let vote_average: Double
    let vote_count: Int
    let genres: [String]
}
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    // 테이블 뷰
    @IBOutlet weak var tableView: UITableView!
    //정렬방식
    @IBOutlet weak var sortButton: UIButton!
    //장르
    @IBOutlet weak var genreButton: UIButton!
    //검색 텍스트 필드
    @IBOutlet weak var searchMessage: UITextField!
    
    //정렬
    enum SortOption {
        case score
        case reviewCount
    }
    var currentSortOption: SortOption = .score {
        didSet {
            updateSortButton()
        }
    }
    //영화 데이터
    var movies: [Movie] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    //장르버튼
    var selectedGenre: String = "All"
    let genreList = ["All","Action", "Adventure","Comedy", "Crime", "Drama", "Fantasy", "Science Fiction", "Thriller"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
            
        fetchMovies()
    }
    //검색버튼
    @IBAction func findButton(_ sender: UIButton) {
     //performSegue(withIdentifier: "Find", sender: self)
    }
    //화면 이동
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Find" {
            let findCV = segue.destination as! FindViewController
            findCV.findText = searchMessage.text ?? "검색어를 입력해 주세요."
        } else if segue.identifier == "Detail" {
            guard let destinationVC = segue.destination as? DetailViewController,
                let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let movie = movies[indexPath.row]
            destinationVC.getTitle = movie.title
        }
    }
    //영화 정보 가져오기
    func fetchMovies() {
        if let url = Bundle.main.url(forResource: "top100_movies", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let movies = try decoder.decode([Movie].self, from: data)
                self.movies = Array(movies.sorted(by: { $0.vote_average > $1.vote_average }).prefix(20))
                print("Movies loaded: \(self.movies.count)")  // add this line
                print("Movies name :  \(self.movies.first)")
            } catch {
                print("Error: \(error)")
            }
        }
    }
    //정렬
    func sortMovies(_ movies: [Movie], by option: SortOption) -> [Movie] {
        switch option {
        case .score:
            return movies.sorted(by: { $0.vote_average > $1.vote_average })
        case .reviewCount:
            return movies.sorted(by: { $0.vote_count > $1.vote_count })
        }
    }
    //정렬 버튼 선택씨
    @IBAction func didTapSortButton(_ sender: UIButton) {
        switch currentSortOption {
        case .score:
            currentSortOption = .reviewCount
            movies = sortMovies(movies, by: .reviewCount)
        case .reviewCount:
            currentSortOption = .score
            movies = sortMovies(movies, by: .score)
        }
    }
    //버튼 텍스트 변경
    func updateSortButton() {
        switch currentSortOption {
        case .score:
            sortButton.setTitle("리뷰 많은 순", for: .normal)
            sortButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        case .reviewCount:
            sortButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            sortButton.setTitle("평점 높은 순", for: .normal)
        }
    }
    //상세페이지
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // 테이블 관련 메소드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0  
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = movies[indexPath.row]
        
        //순위
        let rank = indexPath.row + 1
        cell.titleLabel.text = "\(rank). \(movie.title)"

        //평점
        let starImageAttachment = NSTextAttachment()
        starImageAttachment.image = UIImage(systemName: "star.fill")
        let starImageString = NSAttributedString(attachment: starImageAttachment)
        
        let review = NSMutableAttributedString()
        review.append(starImageString)
        review.append(NSAttributedString(string: " " + String(movie.vote_average)))
        cell.voteAverageLabel.attributedText = review
        
        //리뷰 수
        let countVote = NSTextAttachment()
        countVote.image = UIImage(systemName: "square.and.pencil")
        let countVoteImageString = NSAttributedString(attachment: countVote)
        
        let reviewCount = NSMutableAttributedString()
        reviewCount.append(countVoteImageString)
        reviewCount.append(NSAttributedString(string: " " + String(movie.vote_count)))
        cell.voteCountLabel.attributedText = reviewCount
        //이미지
        cell.posterImageView.image = UIImage(named: "poster")
        
        return cell
    }
    //장르 선택 버튼
    @IBAction func genreButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Genre", message: nil, preferredStyle: .actionSheet)
        for genre in genreList {
            alert.addAction(UIAlertAction(title: genre, style: .default , handler:{ (UIAlertAction) in
                self.selectedGenre = genre
                self.genreButton.setTitle(genre, for: .normal)
                self.filterMoviesByGenre()
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }
    //장르 선택 -> 정렬
    func filterMoviesByGenre() {
        fetchMovies()
        if selectedGenre != "All" {
            movies = movies.filter { $0.genres.contains(selectedGenre) }
        }
        print("장르별 : \(movies.first)")
        tableView.reloadData()
    }

}
    



