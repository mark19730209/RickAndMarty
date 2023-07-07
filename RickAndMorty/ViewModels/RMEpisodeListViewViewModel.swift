//
//  RMEpisodeListViewViewModel.swift
//  RickAndMorty
//
//  Created by Mark Kim on 2023/6/28.
//

import UIKit

protocol RMEpisodeListViewViewModelDelegate:AnyObject {
    func didLoadInitialEpisodes()
    func didLoadMoreEpisodes(with newIndexPaths:[IndexPath])
    func didSelectEpisode(_ episode:RMEpisode)
}

/// View Model to handle episode list view logic
final class  RMEpisodeListViewViewModel: NSObject {
    
    private var isLoadingMoreCharacters = false
    
    public weak var delegate : RMEpisodeListViewViewModelDelegate?
    
    private let borderColors: [UIColor] = [
        .systemGreen,
            .systemBlue,
            .systemOrange,
            .systemPink,
            .systemPurple,
            .systemRed,
            .systemYellow,
        .systemIndigo,
            .systemMint
    ]
    
    private var episodes:[RMEpisode] = []{
        didSet{
            for episode in episodes {
                let viewModel = RMCharacterEpisodeCollectionViewCellViewModel(
                    episodeDataUrl: URL(string: episode.url),
                    borderColor: borderColors.randomElement() ?? .systemBlue
                )
                if !cellViewModels.contains(viewModel){
                    cellViewModels.append(viewModel)
                }
            }
        }
    }
    
    private var cellViewModels:[RMCharacterEpisodeCollectionViewCellViewModel] = []
    
    private var apiInfo:RMGetAllEpisodesResponse.Info? = nil
    
    /// Fetch initial set of episodes(20)
    public func fetchEpisodes(){
        RMService.shared.execute(
            .listEpisodesRequest,
            expecting: RMGetAllEpisodesResponse.self
        ){[weak self] result in
            switch result{
            case .success(let responseModel):
                let results = responseModel.results
                let info = responseModel.info
                self?.episodes = results
                self?.apiInfo = info
                DispatchQueue.main.async {
                    self?.delegate?.didLoadInitialEpisodes()
                }
//            case .success(let model):
//                print(String(describing: model))
//                print("Total:" + String(model.info.count))
//                print("Page result count: " + String(model.results.count))
//                print("Example image url:" + String(model.results.first?.image ?? "No image"))
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
    
    /// Paginate if addtional episodes are needed
    public func fetchAdditionalEpisodes(url:URL){
        guard !isLoadingMoreCharacters else {
            return
        }
//        print("Fetching more data")
        isLoadingMoreCharacters = true
        /// Fetch characters
        guard let request = RMRequest(url:url) else {
            isLoadingMoreCharacters = false
            return
        }
        RMService.shared.execute(request,
                                 expecting: RMGetAllEpisodesResponse.self){ [weak self] result in
            guard let strongSelf = self else{
                return
            }
            
            switch result{
            case .success(let responseModel):
//                print("Pre-update: \(strongSelf.cellViewModels.count)")
                let moreResults = responseModel.results
                let info = responseModel.info
                strongSelf.apiInfo = info

                let originalCount = strongSelf.episodes.count
                let newCount = moreResults.count
                let total = originalCount+newCount
                let startingIndex = total - newCount
                let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex+newCount)).compactMap({
                    return IndexPath(row: $0, section: 0)
                })
//                print(indexPathsToAdd)
                strongSelf.episodes.append(contentsOf: moreResults)
//                print("Post-update \(strongSelf.cellViewModels.count)")
                DispatchQueue.main.async {
                    strongSelf.delegate?.didLoadMoreEpisodes(
                        with: indexPathsToAdd
                    )
                    strongSelf.isLoadingMoreCharacters = false
                }
            case .failure(let failure):
                print(String(describing: failure))
                self?.isLoadingMoreCharacters = false
            }
            
        }

    }

    public var shouldShowLoadMoreIndigator:Bool{
        return apiInfo?.next != nil
//        return false
    }
}

// MARK - CollectionView
extension RMEpisodeListViewViewModel : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
//        return 20
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RMCharacterEpisodeCollectionViewCell.cellIdentifer,
            for: indexPath
        ) as? RMCharacterEpisodeCollectionViewCell else{
            fatalError("Unsupport cell")
        }
//        let viewModel = cellViewModels[indexPath.row]
//        let viewModel = RMEpisodeCollectionViewCellViewModel(
//            characterName: "Mark",
//            characterStatus: .alive,
//            characterImageUrl: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg "))
        cell.configure(with: cellViewModels[indexPath.row])
//        cell.configure(with: viewModel)
//        cell.backgroundColor = .systemGreen
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
              let footer = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: RMFooterLoadingCollectionReusableView.identifier,
            for: indexPath
        ) as? RMFooterLoadingCollectionReusableView else {
            fatalError("Unsupported")
        }
        footer.startAnimating()
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard shouldShowLoadMoreIndigator else {
            return .zero
        }
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = bounds.width-20
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selection = episodes[indexPath.row]
        delegate?.didSelectEpisode(selection)
    }
}

// MARK - ScrollView

extension RMEpisodeListViewViewModel:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadMoreIndigator,
              !isLoadingMoreCharacters,
              !cellViewModels.isEmpty,
              let nextUrlString = apiInfo?.next,
              let url = URL(string: nextUrlString) else{
            return
        }

        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false){ [weak self] t in
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height
            
            if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120){
                self?.fetchAdditionalEpisodes(url: url)
            }
            t.invalidate()
        }
    }
    
}
