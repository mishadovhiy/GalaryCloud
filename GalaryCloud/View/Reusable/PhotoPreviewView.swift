//
//  PhotoPreviewView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 18.11.2025.
//

import SwiftUI

struct PhotoPreviewView: View {
    let imageSelection: ImageSelection?
    let sideImages: [SwipeDirection: FetchFilesResponse.File?]
    let didDeleteImage:()->()
    let imageSwiped: (_ direction: SwipeDirection) -> ()
    @State private var selection: Int = 1
    
    var body: some View {
        VStack(content: {
            Spacer().frame(height: 30)
            PageRepresentable(views: pageList.compactMap({
                .galary(.init(username: "hi@mishadovhiy.com", fileName: $0.originalURL))
            }), didDeleteImage: didDeleteImage) { newIndex in
                imageSwiped(newIndex == 0 ? .left : .right)
            }
        })
        .background(.black)
    }
    
    var pageList: [FetchFilesResponse.File] {
        return [
            (sideImages[.left] ?? .init(originalURL: "", date: "")) ?? .init(originalURL: "", date: ""),
            imageSelection?.file ?? .init(originalURL: "", date: ""),
            (sideImages[.right] ?? .init(originalURL: "", date: "")) ?? .init(originalURL: "", date: "")
        ]
        //.filter({
//        $0 != nil && $0??.originalURL != nil
//        })
        //as! [FetchFilesResponse.File]
    }
    
    enum SwipeDirection {
        case left, right
    }
}

struct PageRepresentable: UIViewControllerRepresentable {
    let views: [CachedAsyncImage.PresentationType]
    let didDeleteImage:()->()

    var newIndex: ((_ newIndex: Int) -> ())? = nil
    @Environment(\.dismiss) private var dismiss

    func setViewController(_ vc: PageController) {
        print(views.count, " grefdwsa ")
        vc.pages = views
    }
    
    func makeUIViewController(context: Context) -> PageController {
        let vc = PageController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        vc.didDeleteImage = didDeleteImage
        setViewController(vc)
        vc.newIndex = newIndex
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PageController, context: Context) {
        if uiViewController.pages.first?.galaryModel == views.first?.galaryModel {
            return
        }
        uiViewController.didDeleteImage = didDeleteImage
        setViewController(uiViewController)
//        uiViewController.setViewControllers([ uiViewController.pages[1]],
//                              direction: .forward,
//                              animated: false)
    }
}

class PageController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var didDeleteImage:(()->())?

    var pages: [CachedAsyncImage.PresentationType] = [] {
        didSet {
            reloadViewControllers()
        }
    }
    var newIndex: ((_ newIndex: Int) -> ())? = nil
    var viewControllerList: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        setViewControllers([viewControllerList[1]],
                           direction: .forward,
                           animated: false)
    }
    
    func reloadViewControllers() {
        viewControllerList = pages.compactMap({
            UIHostingController(rootView: CachedAsyncImage(presentationType: $0, didDeleteImage: didDeleteImage))
        })
        if viewControllerList.count >= 3 {
            viewControllerList.first?.view.alpha = 0
            viewControllerList.last?.view.alpha = 0
        }
        
        setViewControllers([viewControllerList[1]],
                           direction: .forward,
                           animated: false)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let visibleVC = viewControllers?.first,
              let index = viewControllerList.firstIndex(of: visibleVC) else { return }

        print("Animation finished → current page:", index)
        newIndex?(index)
//        if !completed {
//            return
//        }
//        newIndex?(Int(previousViewControllers.first?.view.layer.name ?? "") ?? 0)
//        print(Int(previousViewControllers.first?.view.layer.name ?? "") ?? 0, " tgerfwed ")

    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllerList.firstIndex(of: viewController), index > 0 else { return nil }
        return viewControllerList[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let index = viewControllerList.firstIndex(of: viewController),
              index < viewControllerList.count - 1 else { return nil }
        return viewControllerList[index + 1]
    }
    
    
}
