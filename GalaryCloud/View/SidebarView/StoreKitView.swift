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
    @Binding var privacyPresentingType: HTMLBlockPresenterView.URLType?
    
    var purchuasedProductID: String {
        db.storeKitService.activeSubscription?.id ?? ""
    }
    
    init(db: DataBaseService, privacyPresentingType: Binding<HTMLBlockPresenterView.URLType?>) {
        self._privacyPresentingType = .init(projectedValue: privacyPresentingType)
        self._storeKitService = StateObject(wrappedValue: .init(needAllProducts: true, productIDs: db.db?.generalAppParameters?.storeKitSubscription.proGroup.compactMap({
            $0.id
        }) ?? []))
    }
    
    var body: some View {
        TabView {
            ForEach(storeKitService.allProducts, id: \.id) { product in
#if os(watchOS)
                ScrollView(.vertical) {
                    productContent(product)
                }
#else
                productContent(product)
#endif
            }
        }
        .foregroundColor(.primaryText)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .background(.primaryContainer)
        .background(content: {
            ClearBackgroundView()
        })
        .overlay(content: {
#if os(tvOS)
            VStack {
                privacyButtons
                Spacer()
            }
#endif
        })
#if !os(watchOS)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Privacy Policy", action: {
                    privacyPresentingType = .privacyPolicy
                })
                .tint(.primaryText)
                .font(.footnote)
                .font(.system(size: 9))
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Terms of use", action: {
                    privacyPresentingType = .termsOfUse
                })
                .tint(.primaryText)
                .font(.footnote)
                .font(.system(size: 9))
            }
        }
#endif
        .onAppear {
            Task {
                await db.storeKitService.fetchActiveProducts(force: true)
            }
        }
        #if os(watchOS) || os(tvOS)
        .sheet(isPresented: .init(get: {
            privacyPresentingType != nil
        }, set: {
            if !$0 {
                privacyPresentingType = nil
            }
        })) {
            HTMLBlockPresenterView(urlType: privacyPresentingType ?? .privacyPolicy)
                .presentationDetents([.medium])
        }
        #endif
    }
    
    var restorePurchuaseButton: some View {
        Button("Restore\nPurchase", action: {
            storeKitService.restorePurchases(db: db)
        })
        .padding(.vertical, 3)
        .padding(.horizontal, 5)
        .multilineTextAlignment(.leading)
        .foregroundColor(.secondaryContainer)
        .tint(.secondaryContainer)
        .font(.system(size: 9))
        .background(.secondaryText.opacity(0.4))
        .cornerRadius(6)
    }
    
    @ViewBuilder
    func productButtons(
        _ product: Product,
        isPurchuased: Bool) -> some View {
            restorePurchuaseButton
            
            Spacer()
            expirationDate(product, isPurchuased: isPurchuased)
            Button("Subscribe") {
                buyPressed(product)
            }
#if os(tvOS)
            .foregroundColor(.accentColor)
            .tint(.accentColor)
#endif
            .disabled(isPurchuased)
            .frame(alignment: .trailing)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
#if !os(tvOS)
            .modifier(LoadingButtonModifier(isLoading: false, type: .middle))
#endif
        }
    
    var privacyButtons: some View {
        HStack {
            Button("Privacy Policy", action: {
                privacyPresentingType = .privacyPolicy
            })
            .tint(.primaryText)
            .font(.footnote)
            .font(.system(size: 9))
            Button("Terms of use", action: {
                privacyPresentingType = .termsOfUse
            })
            .tint(.primaryText)
            .font(.footnote)
            .font(.system(size: 9))
        }
    }
    
    @ViewBuilder
    func productContent(_ product: Product) -> some View {
        let isPurchuased = purchuasedProductID == product.id
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 2) {
                Text(product.displayName)
#if os(watchOS) || os(tvOS)
                    .font(.system(size: 12, weight: .semibold))
#else
                    .font(.title)
#endif
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
            #if os(tvOS)
            Text("You will receive additional cloud space to store you content, after the purchase")
                .foregroundColor(.primaryText)
            #endif
#if os(watchOS)
            VStack(spacing: 20) {
                productButtons(product, isPurchuased: isPurchuased)
            }
#else
            HStack {
                productButtons(product, isPurchuased: isPurchuased)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
#endif
            
            #if os(watchOS)
            Spacer().frame(height: 40)
            privacyButtons
            #endif
        }
#if os(tvOS)
        .frame(maxWidth: .infinity, alignment: .leading)
#else
        .frame(maxWidth: 270, alignment: .leading)
#endif
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
        } else {
            Text("auto-renewed\nSubscription")
                .frame(alignment: .trailing)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 8))
                .foregroundColor(.secondaryText)
            
                .background(content: {
                    HStack(alignment: .bottom) {
                        Text("¡")
                            .multilineTextAlignment(.center)
                            .blendMode(.destinationOut)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.primaryText)
                            .frame(width: 13, height: 13)
                            .offset(x:0.5, y: -1)
                            .background(.secondaryText)
                            .cornerRadius(30)
                            .compositingGroup()
                            .offset(x: -14, y: 7)
                        Spacer()
                    }
                })
                .onTapGesture {
                    subscriptionReneviewalDetailsPresenting.toggle()
                }
#if !os(watchOS)
#if !os(tvOS)
            
                .popover(isPresented: $subscriptionReneviewalDetailsPresenting, attachmentAnchor: .point(.top), arrowEdge: .top) {
                    if #available(iOS 16.4, *) {
                        reneviewDetails
                            .presentationBackground(.clear)
                    } else {
                        reneviewDetails
                    }
                }
#endif
#endif
        }
    }
    
    var reneviewDetails: some View {
        VStack(alignment: .leading, spacing: 5, content: {
            Text("Subscription renews automatically")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Unless canceled at least 24 hours before the end of the current period.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(0.7)
        })
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
        .font(.system(size: 12))
        //            .minimumScaleFactor(0.3)
        .foregroundColor(.primaryText)
        .presentationDetents([.height(100), .medium])
        .background {
            ClearBackgroundView()
        }
        .colorScheme(.dark)
        .preferredColorScheme(.dark)
    }
    
    @State var subscriptionReneviewalDetailsPresenting = false
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
