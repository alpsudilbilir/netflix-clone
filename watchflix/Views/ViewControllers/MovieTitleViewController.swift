//
//  MovieTitleViewController.swift
//  watchflix
//
//  Created by Alpsu Dilbilir on 28.09.2022.
//

import UIKit
import SDWebImage
import SnapKit

protocol MovieTitleViewControllerDelegate: AnyObject {
    func toggleFavorites(_ button: WFSymbolButton)
    func toggleWatchlist(_ button: WFSymbolButton)
}

class MovieTitleViewController: UIViewController {
    
    private let movieImageView  = WFImageView(cornerRadius: 25, border: true, contentMode: .scaleToFill)
    private let titleLabel      = WFTitleLabel()
    private let yearLabel       = WFLabel(fontSize: 14, weight: .regular, textAlignment: .natural)
    private let infoLabel       = WFLabel(fontSize: 14, weight: .regular, textAlignment: .natural)
    private let movieQuote      = WFLabel(fontSize: 14, weight: .regular, textAlignment: .natural)
    private let userScoreLabel  = WFLabel(fontSize: 14, weight: .bold, textAlignment: .center)
    private let favoriteButton  = WFSymbolButton(symbol: SFSymbols.heart)
    private let watchlistButton = WFSymbolButton(symbol: SFSymbols.bookmark)
    private let userScoreCirle  = {
        let roundView = UIView(frame: CGRectMake(20, 20, 50, 50))
        roundView.backgroundColor    = UIColor.secondarySystemBackground
        roundView.layer.cornerRadius = roundView.width / 2
        return roundView
    }()
    
    weak var delegate: MovieTitleViewControllerDelegate?
    var movieDetail  : MovieDetailsResponse
    
    init(movieDetail: MovieDetailsResponse) {
        self.movieDetail = movieDetail
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        setupViews()
        configureButtons()
        layoutUI()
        configure(with: movieDetail)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let views = [movieImageView, titleLabel, yearLabel, infoLabel, movieQuote, userScoreCirle, favoriteButton, watchlistButton]
        views.forEach { view.addSubview($0) }
        userScoreCirle.addSubview(userScoreLabel)
    }
    private func configureButtons() {
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        watchlistButton.addTarget(self, action: #selector(didTapWatchlist), for: .touchUpInside)
        initializeButtonSymbols()
    }
    
    private func initializeButtonSymbols() {
        PersistenceService.getMovies(type: .watchlist) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movies):
                if movies.contains(where: { $0.id == self.movieDetail.id }) {
                    self.watchlistButton.configure(with: SFSymbols.bookmarkFill)
                } else { self.watchlistButton.configure(with: SFSymbols.bookmark) }
            case .failure(let error):
                print(error)
            }
        }
        PersistenceService.getMovies(type: .favorite) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movies):
                if movies.contains(where: { $0.id == self.movieDetail.id }) {
                    self.favoriteButton.configure(with: SFSymbols.heartFill)
                } else { self.favoriteButton.configure(with: SFSymbols.heart) }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc private func didTapFavorite() {
        delegate?.toggleFavorites(favoriteButton)
    }
    
    @objc private func didTapWatchlist() {
        delegate?.toggleWatchlist(watchlistButton)
    }
    
    private func layoutUI() {
        movieImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.width.equalTo(150)
            make.height.equalTo(190)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(movieImageView.snp.trailing).offset(5)
            make.trailing.equalTo(view.snp.trailing).offset(-5)
            make.height.equalTo(24)
        }
        yearLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.equalTo(movieImageView.snp.trailing).offset(5)
            make.trailing.equalTo(view.snp.trailing).offset(-5)
            make.width.lessThanOrEqualTo(view.width - movieImageView
                .width)
        }
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(yearLabel.snp.bottom).offset(5)
            make.leading.equalTo(movieImageView.snp.trailing).offset(5)
            make.trailing.equalTo(view.snp.trailing).offset(-5)
            make.height.greaterThanOrEqualTo(20)
        }
        movieQuote.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(5)
            make.leading.equalTo(movieImageView.snp.trailing).offset(5)
            make.trailing.equalTo(view.snp.trailing).offset(-5)
            make.height.greaterThanOrEqualTo(20)
        }
        watchlistButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalTo(movieImageView.snp.trailing).offset(10)
            make.width.height.equalTo(25)
        }
        favoriteButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalTo(watchlistButton.snp.trailing).offset(35)
            make.width.height.equalTo(25)
        }
        
        userScoreCirle.snp.makeConstraints { make in
            make.bottom.equalTo(movieImageView.snp.bottom)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(50)
        }
        userScoreLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
    
    func configure(with model: MovieDetailsResponse) {
        configureScoreLabel(with: model)
        configureYearLabel(with: model)
        configureInfoLabel(with: model)
        titleLabel.text = model.title
        movieQuote.text = model.tagline
        movieImageView.sd_setImage(with: URL(string: APIConstants.baseImageURL + model.poster_path))
    }
    
    private func configureScoreLabel(with model: MovieDetailsResponse) {
        let score           = Int(model.vote_average * 10.0)
        let percentageScore = model.vote_average / 10
        userScoreLabel.text = "\(score)﹪"
        configureCircleStroke(with: percentageScore)
    }
    
    private func configureYearLabel(with model: MovieDetailsResponse) {
        let releaseYear = model.release_date.components(separatedBy: "-").first ?? ""
        yearLabel.text = "Year: \(releaseYear)"
    }
    
    private func configureInfoLabel(with model: MovieDetailsResponse) {
        var genreString = ""
        model.genres.forEach { genre in
            if genre.name != model.genres.last?.name {
                genreString += "\(genre.name), "
            } else { genreString += genre.name }
        }
        let movieTime      = model.runtime ?? 0
        let hour           = movieTime / 60
        let minute         = movieTime % 60
        let durationString = "\(hour)h \(minute)m"
        infoLabel.text     = genreString + " ・ " + durationString
    }
    
    private func configureCircleStroke(with score: Double) {
        let circlePath = UIBezierPath(arcCenter: CGPoint (x: userScoreCirle.width / 2, y: userScoreCirle.width / 2),
                                      radius: userScoreCirle.width / 2,
                                      startAngle: CGFloat(-0.5 * Double.pi),
                                      endAngle: CGFloat(1.5 * Double.pi),
                                      clockwise: true)
        let circleShape         = CAShapeLayer()
        circleShape.path        = circlePath.cgPath
        circleShape.strokeColor = UIColor.yellow.cgColor
        circleShape.fillColor   = UIColor.white.withAlphaComponent(0.00001).cgColor
        circleShape.lineWidth   = 5
        circleShape.strokeStart = 0.0
        circleShape.strokeEnd   = score
        userScoreCirle.layer.addSublayer(circleShape)
    }
}
