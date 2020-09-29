/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

@objc public protocol DrawViewDelegate: class{
  func drawView(_ source: DrawView, didAddLine line: LineShape)
  func drawView(_ source: DrawView, didAddPoint point: CGPoint)
}

public class DrawView: UIView {
  
  let multicast = MulticastDelegate<DrawViewDelegate>()
  
  func addDelegate(_ delegate: DrawViewDelegate){
    multicast.addDelegate(delegate)
  }
  
  func removeDelegate(_ delegate: DrawViewDelegate){
    multicast.removeDelegate(delegate)
  }
  
  
  
  
  
  // MARK: - Instance Properties
  public var lineColor: UIColor = .black
  public var lineWidth: CGFloat = 5.0
  public var lines: [LineShape] = []
  
  
  public lazy var states = [AcceptInputState.identifier: AcceptInputState(view: self),
                            AnimateState.identifier: AnimateState(view:self),
                            ClearState.identifier: ClearState(view: self),
                            CopyState.identifier: CopyState(view: self)]
  public lazy var currentState = states[AcceptInputState.identifier]
  
  @IBInspectable public var scaleX: CGFloat = 1 {
    didSet { applyTransform() }
  }
  @IBInspectable public var scaleY: CGFloat = 1 {
    didSet { applyTransform() }
  }
  private func applyTransform() {
    layer.sublayerTransform = CATransform3DMakeScale(scaleX, scaleY, 1)
  }
  
  // MARK: - UIResponder
  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    currentState?.touchesBegan(touches, with: event)
    
  }
  
  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    currentState?.touchesMoved(touches, with: event)
  }
  
  // MARK: - Actions
  public func animate() {
    currentState?.animate()
  }
  
  public func copyDrawView(_ view: DrawView){
    currentState?.copyDrawView(view)
  }
  
  private func setSublayersStrokeEnd(to value: CGFloat) {
    currentState?.setSublayersStrokeEnd(to: value)
  }
  
  private func animateStrokeEnds(of layers: [CALayer], at index: Int) {
    currentState?.animateStrokeEnds(of: layers, at: index)
  }
  
  public func clear() {
    currentState?.clear()
  }
}

extension DrawView: DrawViewDelegate{
  public func drawView(_ source: DrawView, didAddPoint point: CGPoint) {
    currentState?.addPoint(point)
  }
  public func drawView(_ source: DrawView, didAddLine line: LineShape) {
    let line = line.copy() as LineShape
    currentState?.addLine(line)
  }
}
