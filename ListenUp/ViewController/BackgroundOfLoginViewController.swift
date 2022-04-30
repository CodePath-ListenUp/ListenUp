//
//  BackgroundOfLoginViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/30/22.
//

import SwiftUI
import UIKit

struct LoginBackgroundView: View {
    let colors: [Color] = [.red,.purple,.pink,.orange]
    
    let widthBase: CGFloat = 30
//    let calculatedDimension: (Int) -> CGFloat = { givenInt in return widthBase*pow(2.0, CGFloat(givenInt)) }
    var body: some View {
        GeometryReader { geometry in
            ForEach(10..<20, id: \.self) { i in
                ZStack {
                    BouncingCircle(x: CGFloat.random(in: 0.0..<geometry.size.width), y: CGFloat.random(in: 0.0..<geometry.size.height), circleFrame: widthBase * CGFloat(Double(i)), width: geometry.size.width, height: geometry.size.height)
                        .opacity(Double.random(in: 20.0..<50.0))
                        .foregroundColor(colors.randomElement())
                        .ignoresSafeArea()
                }
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .blur(radius: 50.0)
       
    }
}

struct BouncingCircle: View {
    @State var x: CGFloat
    @State var y: CGFloat
    
    let circleFrame: CGFloat
    
    let width: CGFloat
    let height: CGFloat
    
    @State var xspeed = CGFloat.random(in: 3.0...5.0) * [1.0,-1.0].randomElement()!
    @State var yspeed = CGFloat.random(in: 3.0...5.0) * [1.0,-1.0].randomElement()!
    
    let animationTime = 0.04
    
    var body: some View {
        Circle()
            .position(x: x, y: y)
            .frame(width: circleFrame, height: circleFrame)
            .animation(
                Animation.linear(duration: 1.0)
            ,value: x)
            .animation(
                Animation.linear(duration: 1.0)
            ,value: y)
            .onAppear {
                doAnimation(width: width, height: height)
            }
            .ignoresSafeArea()
        
    }
    
    
    func doAnimation(width: CGFloat, height: CGFloat) {
        
        withAnimation(.linear(duration: animationTime)) {
            x += xspeed
            y += yspeed
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
            if x <= 0 || x+circleFrame >= width {
                xspeed = xspeed * -1
            }
            if y <= 0 || y+circleFrame >= height {
                yspeed = yspeed * -1
            }
            doAnimation(width: width, height: height)
        }
    }
}

class BackgroundOfLoginViewController: UIViewController {
    var backgroundView = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView = UIHostingController(rootView: LoginBackgroundView())
        backgroundView.view.layer.opacity = 0.5
        addChild(backgroundView)
        view.addSubview(backgroundView.view)
        setupContraints()
    }
    
    fileprivate func setupContraints() {
        backgroundView.view.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
}
