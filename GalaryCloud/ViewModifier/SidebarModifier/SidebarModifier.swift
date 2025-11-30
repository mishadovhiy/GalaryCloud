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

    var sidebarButtonView: some View {
        VStack {
            HStack {
                Button {
                    model.toggleMenuPressed()
                } label: {
                    HStack(spacing:0, content: {
                        ZStack(
                            content: {
                                menuIcon(.menu,
                                         scrollPercent: model.toOpenScrollingPercent)

                                menuIcon(.close,
                                         scrollPercent: model.toCloseScrollingPercent)
                            })
                        .frame(width: 16, height: 16)
                        .padding(5)
                        .background(.white.opacity(0.5))
                        .cornerRadius(6)
                        .padding(3)
                        ZStack(content: {
                            Text("menu")
                                .lineLimit(1)
                                .frame(width: 50)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.black)
                                .shadow(radius: 10)
                        })
                        .clipped()

                            .frame(width: 50 * model.dragPercent, alignment: .leading)

                    })

                    .background(.white.opacity(0.2))
                    .cornerRadius(7)
                    .padding(.top, 5)
                    .padding(.leading, 5)
                }

                Spacer().frame(maxWidth: .infinity)
            }
            Spacer().frame(maxHeight: .infinity)
        }
    }

    var draggableView: some View {
        VStack {
            RoundedRectangle(cornerRadius: 15)
            
                .fill(.white.opacity(0.001))
                .overlay {
                    HStack {
                        sidebarButtonView
                        Spacer()
                    }
                    .offset(y: -10 * model.dragPercent)
                }
                .frame(height: 30)
                .offset(y: model.dragPositionX)
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
            Spacer().frame(maxHeight: .infinity)
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
        .stroke(.black, lineWidth: 2)
        .shadow(radius: 4)
        .scaleEffect(model.isScrollActive ? scrollPercent : iconActive ? 1 : 0.5)
        .animation(.smooth, value: model.isOpened)
    }
}
