//
//  SwipePanGesture.swift
//  Marush
//
//  Created by S2S Company on 30.01.2025.
//
import SwiftUI

struct SwipePanGesture: UIViewRepresentable {
    
    var onChanged: (CGFloat) -> Void
    var onEnded: (CGFloat) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onChanged: onChanged, onEnded: onEnded)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let pan = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(_:))
        )
        pan.delegate = context.coordinator
        view.addGestureRecognizer(pan)
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.onChanged = onChanged
        context.coordinator.onEnded = onEnded
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        
        var onChanged: (CGFloat) -> Void
        var onEnded: (CGFloat) -> Void
        
        private var isHorizontal = false
        private var decided = false
        
        init(onChanged: @escaping (CGFloat) -> Void,
             onEnded: @escaping (CGFloat) -> Void) {
            self.onChanged = onChanged
            self.onEnded = onEnded
        }
        
        // MARK: - Pan Handler
        @objc func handlePan(_ sender: UIPanGestureRecognizer) {
            let translation = sender.translation(in: sender.view)

            switch sender.state {
            case .changed:
                if !decided {
                    if abs(translation.x) > 10 && abs(translation.x) > abs(translation.y) {
                        isHorizontal = true     // horizontal swipe detected
                        decided = true
                    } else if abs(translation.y) > 10 {
                        isHorizontal = false    // vertical scroll → let system scroll
                        decided = true
                    }
                }

                if isHorizontal {
                    onChanged(translation.x)
                }

            case .ended, .cancelled:
                if isHorizontal {
                    onEnded(translation.x)
                }
                decided = false
                isHorizontal = false

            default: break
            }
        }
        
        // MARK: - Allow scroll + swipe simultaneously
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        // MARK: - Do NOT block vertical scroll
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            let pan = gestureRecognizer as! UIPanGestureRecognizer
            let velocity = pan.velocity(in: pan.view)
            
            // If vertical scroll is stronger → let ScrollView handle it
            return abs(velocity.x) > abs(velocity.y)
        }
    }
}


struct ScrollCompatibleSwipeGesture: UIGestureRecognizerRepresentable {

    let onUpdate: (CGFloat) -> Void
    let onEnd: (CGFloat) -> Void
    
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer()
        gesture.delegate = context.coordinator
        return gesture
    }
    
    func updateUIGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer, context: Context) {}

    func handleUIGestureRecognizerAction(_ gestureRecognizer: UIPanGestureRecognizer, context: Context) {

        let translation = gestureRecognizer.translation(in: gestureRecognizer.view)

        switch gestureRecognizer.state {
        case .changed:
            context.coordinator.handlePanChanged(translation, callback: onUpdate)

        case .ended, .cancelled:
            context.coordinator.handlePanEnded(translation, callback: onEnd)

        default:
            break
        }
    }

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {

        private var isHorizontal = false
        private var started = false

        func handlePanChanged(_ translation: CGPoint, callback: (CGFloat) -> Void) {

            if !started {
                // Decide horizontal vs vertical
                if abs(translation.x) > 12 && abs(translation.x) > abs(translation.y) {
                    isHorizontal = true     // horizontal wins
                    started = true
                } else if abs(translation.y) > 12 {
                    isHorizontal = false    // vertical wins → let scroll work
                    started = true
                } else {
                    return
                }
            }

            if isHorizontal {
                callback(translation.x)
            }
        }

        func handlePanEnded(_ translation: CGPoint, callback: (CGFloat) -> Void) {
            if isHorizontal {
                callback(translation.x)
            }
            isHorizontal = false
            started = false
        }

        // Important: allow ScrollView + our gesture
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }

        // Important: do NOT block scroll unless horizontal
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            let pan = gestureRecognizer as! UIPanGestureRecognizer
            let velocity = pan.velocity(in: pan.view)

            // If vertical velocity is higher → let scrollView own it.
            return abs(velocity.x) > abs(velocity.y)
        }
    }
}
