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
    }
    //영화 정보 렌더링
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
                        let movieRateText = self.symbolTextMaker(symbolName: "star.fill", text:String(movieDetail.vote_average))
                        self.movieRate.attributedText = movieRateText
                        //개봉일
                        let realseDateText = self.symbolTextMaker(symbolName: "calendar.circle", text: String(movieDetail.release_date))
                        self.releaseDate.attributedText = realseDateText
                        //런타임
                        let runtimeText = self.symbolTextMaker(symbolName: "clock", text: String("\(movieDetail.runtime)분"))
                        self.runtime.attributedText = runtimeText
                        //장르
                        let genreText = self.symbolTextMaker(symbolName: "popcorn.circle", text: movieDetail.genres.joined(separator: ", "))
                        self.genre.attributedText = genreText

                        //줄거리
                        self.overview.text = movieDetail.overview
                        
                        //포스터
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
    //아이콘 추가
    func symbolTextMaker(symbolName: String, text: String) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: symbolName)
        let attachmentString = NSAttributedString(attachment: attachment)
        let completeText = NSMutableAttributedString()
        completeText.append(attachmentString)
        let text = NSAttributedString(string: " \(text)")
        completeText.append(text)

        return completeText
    }

}
