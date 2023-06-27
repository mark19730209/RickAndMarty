//
//  RMCharacterEpisodeCollectionViewCellViewModel.swift
//  RickAndMorty
//
//  Created by Mark Kim on 2023/6/21.
//

import Foundation

protocol RMEpisodeDataRender {
    var name: String {get}
    var air_date: String {get}
    var episode: String {get}

}

final class RMCharacterEpisodeCollectionViewCellViewModel{
    private let episodeDataUrl: URL?
    private var isFetching = false
    private var dataBlock: ((RMEpisodeDataRender) -> Void)?
    private var episode: RMEpisode?{
        didSet {
            guard let model = episode else{
                return
            }
            dataBlock?(model)
        }
    }
    
    // MARK: - Init
    
    init( episodeDataUrl: URL?){
        self.episodeDataUrl = episodeDataUrl
    }
    
    // MARK: - Public
    
    public func registerForData(_ block: @escaping (RMEpisodeDataRender) -> Void){
        self.dataBlock = block
    }
    
    public func fetchEpisode(){
//        print(episodeDataUrl)
        guard !isFetching else {
            if let model = episode {
                dataBlock?(model)
            }
            return
        }
        
        guard let url = episodeDataUrl,
                let request = RMRequest(url:url) else{
            return
        }
        
        isFetching = true
//        print("Created:")
        RMService.shared.execute(request, expecting: RMEpisode.self){ [weak self] result in
            switch result {
            case .success(let model):
                DispatchQueue.main.async {
                    self?.episode = model
                }
//                print(String(describing: success.id))
            case .failure(let failure):
                print(String(describing: failure))
            }
        }
    }
}
