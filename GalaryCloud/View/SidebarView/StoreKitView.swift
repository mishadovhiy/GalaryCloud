//
//  StoreKitView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 23.11.2025.
//

import SwiftUI
import StoreKit

struct StoreKitView: View {
    
    @StateObject private var storeKitService: StoreKitService
    @EnvironmentObject private var db: DataBaseService
    
    init(db: DataBaseService) {
        self._storeKitService = StateObject(wrappedValue: .init(needAllProducts: true, productIDs: db.db?.generalAppParameters?.storeKitSubscription.proGroup.compactMap({
            $0.id
        }) ?? []))
    }
    @State var id: UUID = .init()
    var body: some View {
        TabView {
            ForEach(storeKitService.allProducts, id: \.id) { product in
                VStack(alignment: .leading, spacing: 10) {
                    productContent(product)
                }
                .frame(maxWidth: 230, alignment: .leading)
                
            }
        }
        .foregroundColor(.primaryText)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .background(content: {
            ClearBackgroundView()
        })
        .background(.primaryContainer)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Privacy Policy") {
                    HTMLBlockPresenterView(urlType: .privacyPolicy)
                }
//                .modifier(LinkButtonModifier())
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Terms of use") {
                    HTMLBlockPresenterView(urlType: .termsOfUse)
                }
//                .modifier(LinkButtonModifier())
            }
        }
    }

    @ViewBuilder
    func productContent(_ product: Product) -> some View {
        HStack(spacing: 2) {
            Text(product.displayName)
                .font(.title)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primaryText)
            Spacer()
            Text("$" + "\(product.price)")
                .font(.footnote)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.2)
                .frame(width: 40)
            .overlay {
                HStack {
                    Spacer()
                    Text("/ month")
                        .lineLimit(nil)
                        .font(.system(size: 7, weight: .medium))
                        .foregroundColor(.primaryText.opacity(0.3))
                        .multilineTextAlignment(.trailing)
                        .offset(y: -10)
                        .shadow(color:.primaryText.opacity(0.3), radius: 4)
                }
                    
            }
        }
        Text(product.description)
            .foregroundColor(.primaryText)

        HStack {
            Button("Subscribe") {
                buyPressed(product)
            }
            .frame(alignment: .trailing)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .modifier(LoadingButtonModifier(isLoading: false, type: .middle))
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    
    func buyPressed(_ product: Product) {
        Task {
            do {
                let request = await storeKitService.buy(product: product)
                switch request {
                case .success(let success):
                    print(success, " grvefcds")
                    if success {
                        Task {
                            await db.storeKitService.fetchActiveProducts(force: true)
                        }
                    }
                case .failure(let failure):
                    print(failure.unparcedDescription, " grterfwdesa ")
                }
            }
        }
    }
}
