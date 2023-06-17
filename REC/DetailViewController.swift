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
struct Review {
    let rate: Int
    let content: String
}

class DetailViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var getTitle: String?
    
    
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var movieRate: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var runtime: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var overview: UITextView!
    
    @IBOutlet weak var writeReview: UITextField!
    @IBOutlet weak var sendReview: UIButton!
    @IBOutlet weak var reviewTable: UITableView!
    
    var reviews = [Review]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let title = getTitle {
            fetchMovieDetails(title: title)
            print("dndndndn \(title)")
        }
        reviewTable.delegate = self
        reviewTable.dataSource = self
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
    //사용자 후기 작성.
    @IBAction func sendReviewClicked(_ sender: UIButton) {
        if writeReview.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true {
            let alert = UIAlertController(title: "Error", message: "내용을 입력해 주세요!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let rateMenu = UIAlertController(title: nil, message: "Select Rate", preferredStyle: .actionSheet)
            
            for rate in 1...5 {
                rateMenu.addAction(UIAlertAction(title: "\(String(repeating: "⭐️", count: rate))", style: .default, handler: { [weak self] action in
                    self?.presentReviewConfirm(rate: rate)
                }))
            }
            
            rateMenu.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            
            self.present(rateMenu, animated: true, completion: nil)
        }
    }
    
    func presentReviewConfirm(rate: Int) {
        let reviewConfirm = UIAlertController(title: "후기를 작성하시겠습니까?", message: "", preferredStyle: .alert)
        
        reviewConfirm.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] action in
            if let reviewText = self?.writeReview.text {
                let newReview = Review(rate: rate, content: reviewText)
                self?.reviews.append(newReview)
                self?.reviewTable.reloadData()
                self?.writeReview.text = ""
            }
        }))
        
        reviewConfirm.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(reviewConfirm, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        let review = reviews[indexPath.row]
        cell.customRate.text = "⭐️\(review.rate)"
        cell.review.text = review.content
        return cell
    }
}
