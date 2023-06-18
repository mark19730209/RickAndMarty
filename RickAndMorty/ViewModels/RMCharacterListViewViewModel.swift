//
//  CharacterListViewViewModel.swift
//  RickAndMorty
//
//  Created by Mark Kim on 2023/6/15.
//

import UIKit

protocol RMCharacterListViewViewModelDelegate:AnyObject {
    func didLoadInitialCharacters()
    func didLoadMoreCharacters(with newIndexPaths:[IndexPath])
    func didSelectCharacter(_ character:RMCharacter)
}

/// View Model to handle character list view logic
final class  RMCharacterListViewViewModel: NSObject {
    
    private var isLoadingMoreCharacters = false
    
    public weak var delegate : RMCharacterListViewViewModelDelegate?
    
    private var characters:[RMCharacter] = []{
        didSet{
            for character in characters {
                let viewModel = RMCharacterCollectionViewCellViewModel(
                    characterName: character.name,
                    characterStatus: character.status,
                    characterImageUrl:  URL(string: character.image)
                )
                if !cellViewModels.contains(viewModel){
                    cellViewModels.append(viewModel)
                }
            }
        }
    }
    
    private var cellViewModels:[RMCharacterCollectionViewCellViewModel] = []
    
    private var apiInfo:RMGetAllCharactersResponse.Info? = nil
    
    /// Fetch initial set of characters(20)
    public func fetchCharacters(){
        RMService.shared.execute(.listCharactersRequest, expecting: RMGetAllCharactersResponse.self
        ){[weak self] result in
            switch result{
            case .success(let responseModel):
                let results = responseModel.results
                let info = responseModel.info
                self?.characters = results
                self?.apiInfo = info
                DispatchQueue.main.async {
                    self?.delegate?.didLoadInitialCharacters()
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
    
    /// Paginate if addtional characters are needed
    public func fetchAdditionalCharaters(url:URL){
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
                                 expecting: RMGetAllCharactersResponse.self){ [weak self] result in
            guard let strongSelf = self else{
                return
            }
            
            switch result{
            case .success(let responseModel):
//                print("Pre-update: \(strongSelf.cellViewModels.count)")
                let moreResults = responseModel.results
                let info = responseModel.info
                strongSelf.apiInfo = info

                let originalCount = strongSelf.characters.count
                let newCount = moreResults.count
                let total = originalCount+newCount
                let startingIndex = total - newCount
                let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex+newCount)).compactMap({
                    return IndexPath(row: $0, section: 0)
                })
//                print(indexPathsToAdd)
                strongSelf.characters.append(contentsOf: moreResults)
//                print("Post-update \(strongSelf.cellViewModels.count)")
                DispatchQueue.main.async {
                    strongSelf.delegate?.didLoadMoreCharacters(
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
extension RMCharacterListViewViewModel : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
//        return 20
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RMCharacterCollectionViewCell.cellIdentifier,
            for: indexPath
        ) as? RMCharacterCollectionViewCell else{
            fatalError("Unsupport cell")
        }
//        let viewModel = cellViewModels[indexPath.row]
//        let viewModel = RMCharacterCollectionViewCellViewModel(
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
        let width = (bounds.width-30)/2
        return CGSize(width: width, height: width * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let character = characters[indexPath.row]
        delegate?.didSelectCharacter(character)
    }
}

// MARK - ScrollView
extension RMCharacterListViewViewModel:UIScrollViewDelegate{
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
                self?.fetchAdditionalCharaters(url: url)
            }
            t.invalidate()
        }
    }
    
}
