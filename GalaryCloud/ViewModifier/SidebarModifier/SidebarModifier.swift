//
//  SidebarModifier.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 27.11.2025.
//

import SwiftUI

struct SidebarModifier<SomeView: View>: ViewModifier {
    let targedBackgroundView: SomeView
    let disabled: Bool

    @StateObject var model: PinchMaskedScrollModifierModel = .init()

    func body(content: Content) -> some View {
        let dragPercent = model.dragPercent
        ZStack {
            VStack(content: {
                targedBackgroundView
                    .padding(.bottom, 20)
                    .frame(maxHeight: model.maxScrollX, alignment: .leading)
                Spacer().frame(maxHeight: .infinity)
            })
            .frame(maxHeight: .infinity)
            .zIndex(model.sideBarZindex)


            content
                .disabled(model.isOpened)
                .mask({
                    RoundedRectangle(cornerRadius: 32 * dragPercent)
                        .offset(y: model.dragPositionX)
                        .ignoresSafeArea(.all)
                        .padding(.leading, 27 * dragPercent)
                        .padding(.trailing, 33 * dragPercent)
                        .rotationEffect(.degrees(5 * dragPercent))
                        .animation(.smooth, value: model.isScrollActive)
                })

                .overlay(content: {
                    draggableView
                        .opacity(disabled ? 0 : 1)
                        .animation(.smooth, value: disabled)
                })
                .modifier(ViewSizeReaderModifier(viewSize: .init(get: {
                    .init(width: 0, height: model.viewWidth)
                }, set: { new in
                    model.viewWidth = new.height
                })))
        }
        .onChange(of: disabled) { newValue in
            if model.isOpened {
                withAnimation(.bouncy) {
                    model.toggleMenuPressed()
                }

            }
        }
    }

    var scrollIcons: some View {
        ZStack(
            content: {
                ZStack {
                    menuIcon(.menu,
                             scrollPercent: model.toOpenScrollingPercent)
                    .blendMode(.destinationOut)
                    menuIcon(.menu,
                             scrollPercent: model.toOpenScrollingPercent)
                    .opacity(0.4)
                }
                ZStack {
                    menuIcon(.close,
                             scrollPercent: model.toCloseScrollingPercent)
                    .blendMode(.destinationOut)
                    menuIcon(.close,
                             scrollPercent: model.toCloseScrollingPercent)
                    .opacity(0.4)
                }
            })
    }
    
    var scrollText: some View {
        ZStack(content: {
            Text("menu")
                .lineLimit(1)
                .frame(width: 50)
                .frame(maxWidth: .infinity)
                .foregroundColor(.primaryText)
                .shadow(radius: 10)
                .opacity(0.4)
                .blendMode(.destinationOut)
            Text("menu")
                .lineLimit(1)
                .frame(width: 50)
                .frame(maxWidth: .infinity)
                .foregroundColor(.primaryText)
                .shadow(radius: 10)
                .opacity(0.4)
        })
        .clipped()

            .frame(width: 50 * model.dragPercent, alignment: .leading)
    }
    
    var sidebarButtonView: some View {
        VStack(alignment: .center) {
            Button {
                model.toggleMenuPressed()
            } label: {
                HStack(spacing:0, content: {
                    scrollIcons
                    .frame(width: 16 + (10 * (1 - model.maxDragPercent)), height: 3 + (13 * model.maxDragPercent))
                    .padding(5)
                    .background(content: {
                        BlurView()
                    })
                    .background(.secondaryContainer.opacity(0.3 + (0.2 * model.dragPercent)))
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(.outline), lineWidth: 1)
                    })
                    .cornerRadius(6)
                    .padding(3)
                    scrollText

                })
                .background(content: {
                    BlurView()
                })
                .background(.secondaryContainer.opacity(0.2))
                .cornerRadius(7)
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color(.outline), lineWidth: 1)
                })
                .padding(.top, 5)
                .padding(.leading, 5)
                .compositingGroup()

            }
            Spacer().frame(maxHeight: .infinity)
        }
    }

    var draggableView: some View {
        VStack {
            RoundedRectangle(cornerRadius: 15)
            
                .fill(.white.opacity(0.001))
                .overlay {
                    sidebarButtonView
                    .offset(y: -15 * model.dragPercent)
                }
                .frame(maxHeight: model.isOpened ? .infinity : 30)
                .offset(y: model.dragPositionX)
            #if !os(tvOS)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            model.scrollStarted()
                            model.dragPositionX = value.translation.height + model.lastPosition
                        }
                        .onEnded { _ in
                            model.lastPosition = model.dragPositionX
                            model.scrollEnded()
                        }
                )
            #endif
            Spacer().frame(maxHeight: model.isOpened ? 0 : .infinity)
        }
    }
}

fileprivate extension SidebarModifier {
    @ViewBuilder
    func menuIcon(_ type: MenuIconShape.`Type`,
                  scrollPercent: CGFloat) -> some View {
        var iconActive: Bool {
            switch type {
            case .menu:
                return !model.isOpened
            case .close:
                return model.isOpened
            }
        }

        MenuIconShape(
            type: type
        )
        .trim(
            to: model.isScrollActive ? scrollPercent : iconActive ? 1 : 0
        )
        .stroke(.primaryText, lineWidth: 2)
        .shadow(radius: 4)
        .scaleEffect(model.isScrollActive ? scrollPercent : iconActive ? 1 : 0.5)
        .animation(.smooth, value: model.isOpened)
    }
}
