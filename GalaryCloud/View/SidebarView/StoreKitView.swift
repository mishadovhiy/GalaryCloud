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
    var purchuasedProductID: String {
        db.storeKitService.activeSubscription?.id ?? ""
    }
    
    init(db: DataBaseService) {
        self._storeKitService = StateObject(wrappedValue: .init(needAllProducts: true, productIDs: db.db?.generalAppParameters?.storeKitSubscription.proGroup.compactMap({
            $0.id
        }) ?? []))
    }

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
                .tint(.primaryText)
                .font(.footnote)
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Terms of use") {
                    HTMLBlockPresenterView(urlType: .termsOfUse)
                }
                .tint(.primaryText)
                .font(.footnote)
            }
        }
    }

    @ViewBuilder
    func productContent(_ product: Product) -> some View {
        let isPurchuased = purchuasedProductID == product.id
        HStack(spacing: 2) {
            Text(product.displayName)
                .font(.title)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primaryText)
                .background {
                    if isPurchuased {
                        currentIndicator
                    }
                }
            Spacer()
            price(product)
        }
        description(product)

        HStack {
            expirationDate(product, isPurchuased: isPurchuased)
            Button("Subscribe") {
                buyPressed(product)
            }
            .disabled(isPurchuased)
            .frame(alignment: .trailing)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .modifier(LoadingButtonModifier(isLoading: false, type: .middle))
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    @ViewBuilder
    var currentIndicator: some View {
        HStack(alignment: .top) {
            Text("Current")
                .font(.system(size: 7, weight: .medium))
                .foregroundColor(.secondaryContainer)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(.primaryText.opacity(0.5))
                .cornerRadius(6)
                .shadow(radius: 4)
                .offset(x: 10, y: -8)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    @ViewBuilder
    func description(_ product: Product) -> some View {
        let amount = product.description.numbers ?? 0
        let description = product.description.replacingOccurrences(of: "\(amount)", with: "").replacingOccurrences(of: "GB", with: "")
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(amount.mbOrTbTitle)
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.leading)
                .font(.system(size: 15, weight: .semibold))
            Text(description)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.leading)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func price(_ product: Product) -> some View {
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
    
    @ViewBuilder
    func expirationDate(_ product: Product, isPurchuased: Bool) -> some View {
        if isPurchuased,
            let activeTransaction = db.storeKitService.activeTransactions.first(where: {
            $0.productID == product.id
            }),
            let expirationDate = activeTransaction.expirationDate {
            let expirationDateString = Calendar.current.dateComponents([.year, .month, .day], from: expirationDate).stringDate
            VStack(alignment: .trailing) {
                Text("Active until:")
                    .font(.footnote)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.trailing)
                    
                Text(expirationDateString)
                    .font(.footnote)
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.trailing)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
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
