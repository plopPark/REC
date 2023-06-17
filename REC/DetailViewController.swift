//
//  DetailViewController.swift
//  REC
//
//  Created by 박상준 on 2023/06/16.
//

import UIKit
struct MovieDetail: Codable {
    let title: String
    let vote_average: Double
    let release_date: String
    let runtime: Int
    let genres: [String]
    let overview: String
    let poster_path: String
}

class DetailViewController: UIViewController {
    
    var getTitle: String?
    
    
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var movieRate: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var runtime: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var overview: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let title = getTitle {
            fetchMovieDetails(title: title)
            print("dndndndn \(title)")
        }
        /*
        movieTitle.text = getTitle
        if let movies = loadMovies(), let movieTitle = getTitle {
            if let movie = movies.first(where: { $0.title == movieTitle }) {
                movieRate.text = String(movie.vote_average)
                releaseDate.text = movie.release_date
                runtime.text = String(movie.runtime)
                genre.text = movie.genres.joined(separator: ", ")
                overview.text = movie.overview
                posterImage.image = UIImage(named: "poster")
            }
        }
         */
    }//디드로드 끝
    func fetchMovieDetails(title: String) {
        if let url = Bundle.main.url(forResource: "top100_movies", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let movieList = try decoder.decode([MovieDetail].self, from: data)
                if let movieDetail = movieList.first(where: { $0.title == title }) {
                    print("Movie found: \(movieDetail.title)")  // Debug print
                    DispatchQueue.main.async {
                        //제목
                        self.movieTitle.text = movieDetail.title
                        //평점
                        let attachment = NSTextAttachment()
                        attachment.image = UIImage(systemName: "star.fill")
                        let attachmentString = NSAttributedString(attachment: attachment)
                        let completeText = NSMutableAttributedString()
                        completeText.append(attachmentString)
                        let movieRateText = NSAttributedString(string: " \(String(movieDetail.vote_average))")
                        completeText.append(movieRateText)
                        self.movieRate.text = completeText.string
                        self.movieRate.attributedText = completeText

                        //self.movieRate.text = String(movieDetail.vote_average)
                        
                        //개봉일
                        self.releaseDate.text = movieDetail.release_date
                        //런타임
                        self.runtime.text = String(movieDetail.runtime ?? 0) + "분"
                        //장르
                        self.genre.text = movieDetail.genres.joined(separator: ", ")
                        //줄거리
                        self.overview.text = movieDetail.overview
                        //이미지
                        self.posterImage.image = UIImage(named: "poster")
                        print("UI should be updated now.")  // Debug print
                    }
                } else {
                    print("Movie not found")
                }
            } catch {
                print("Error: \(error)")
            }
        } else {
            print("JSON file not found")
        }
    }
}
