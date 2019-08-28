//
//  SwiftTurf.swift
//  SwiftTurf
//
//  Created by Adolfo Martinelli on 9/13/16.
//  Copyright (c) 2016 AirMap, Inc. All rights reserved.
//

import JavaScriptCore

final public class SwiftTurf {

	private static let sharedInstance = SwiftTurf()
	
	private let context = JSContext()
	
	public enum Units: String {
		case Meters     = "meters"
		case Kilometers = "kilometers"
		case Feet       = "feet"
		case Miles      = "miles"
		case Degrees    = "degrees"
	}
	
	private init() {

		let path = Bundle(for: SwiftTurf.self).path(forResource: "bundle", ofType: "js")!
		var js = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
		
		// Make browserify work
		js = "var window = this; \(js)"
		_ = context?.evaluateScript(js)

		context?.exceptionHandler = { context, exception in
			print(exception as Any)
		}
	}
	
	/// Calculates a buffer for input features for a given radius. Units supported are meters, kilometers, feet, miles, and degrees.
	///
	/// - parameter feature:  input to be buffered
	/// - parameter distance: distance to draw the buffer
	/// - parameter units: .Meters, .Kilometers, .Feet, .Miles, or .Degrees
	/// - parameter steps: controls the number of vertices for drawing curves around points
	///
	/// - returns: Polygon?
	public static func buffer<G: GeoJSONConvertible>(_ feature: G, distance: Double, units: Units = .Meters, steps: Int = 45) -> Polygon? {
		
		let bufferJs = sharedInstance.context?.objectForKeyedSubscript("buffer")!
		let args: [AnyObject] = [feature.geoJSONRepresentation() as AnyObject, distance as AnyObject, ["units": units.rawValue as AnyObject, "steps": steps as AnyObject] as AnyObject]
		
		if let bufferedGeoJSON = bufferJs?.call(withArguments: args)?.toDictionary() {
			return Polygon(dictionary: bufferedGeoJSON)
		} else {
			return nil
		}
	}
	
	/// Takes a Polygon and returns Points at all self-intersections.
	///
	/// - parameter feature: input polygon
	///
	/// - returns: FeatureCollection?
	public static func kinks(_ feature: Polygon) -> FeatureCollection? {
		
		let kinksJs = sharedInstance.context?.objectForKeyedSubscript("kinks")!
		let args: [AnyObject] = [feature.geoJSONRepresentation() as AnyObject]
		
		if let kinks = kinksJs?.call(withArguments: args)?.toDictionary() {
			return FeatureCollection(dictionary: kinks)
		} else {
			return nil
		}
	}
	
	/// Takes two line strings or polygon GeoJSON and returns points of intersection
	///
	/// - parameter feature: line strings or polygon GeoJSON
	///
	/// - returns: FeatureCollection?
	public static func lineIntersect(_ line1: LineString, _ line2: LineString) -> FeatureCollection? {
		
		let js = sharedInstance.context?.objectForKeyedSubscript("lineIntersect")!
		let args: [AnyObject] = [line1.geoJSONRepresentation() as AnyObject, line2.geoJSONRepresentation() as AnyObject]
		
		if let intersect = js?.call(withArguments: args)?.toDictionary() {
			return FeatureCollection(dictionary: intersect)
		} else {
			return nil
		}
	}
	
	/// Takes a point and calulates the location of a destination point given a distance in degrees, radians, miles, or kilometers and bearing in degrees
	///
	/// - parameter point, distance, bearing, and units
	///
	/// - returns: Point?
	public static func destination(point: Point, distance: Double, bearing: Double, units: Units = .Meters) -> Point? {
		
		let js = sharedInstance.context?.objectForKeyedSubscript("destination")!
		let args: [AnyObject] = [point.geoJSONRepresentation()  as AnyObject, distance as AnyObject, bearing as AnyObject, ["units": units.rawValue as AnyObject] as AnyObject]
		
		if let destinationPoint = js?.call(withArguments: args)?.toDictionary() {
			return Point(dictionary: destinationPoint)
		} else {
			return nil
		}
	}
	
	/// Takes two geometries and returns true if the first geometry entiely surrounds the second geometry
	///
	/// - parameter point, distance, bearing, and units
	///
	/// - returns: Boolean
	public static func contains(polygon: Polygon, point: Point?) -> Bool {
		
		guard let point = point else { return false }
		
		let js = sharedInstance.context?.objectForKeyedSubscript("contains")!
		let args: [AnyObject] = [polygon.geoJSONRepresentation()  as AnyObject, point.geoJSONRepresentation()  as AnyObject]
		
		if let doesContain = js?.call(withArguments: args)?.toBool() {
			return doesContain
		} else {
			return false
		}
	}
  
  public static func nearestPointOnLine(line: LineString, point: Point) -> Point {
    let js = sharedInstance.context?.objectForKeyedSubscript("nearestPointOnLine")!
    let args: [AnyObject] = [line.geoJSONRepresentation() as AnyObject, point.geoJSONRepresentation() as AnyObject]
    
    guard let pointOnLineDictionary = js?.call(withArguments: args)?.toDictionary(),
      let pointOnLine = Point(dictionary: pointOnLineDictionary)
      else {
        assertionFailure()
        return point
    }
    return pointOnLine
  }
  
  public static func pointToLineDistance(point: Point, line: LineString, units: Units = .Meters) -> Double {
    let js = sharedInstance.context?.objectForKeyedSubscript("pointToLineDistance")!
    let args: [AnyObject] = [
      point.geoJSONRepresentation() as AnyObject,
      line.geoJSONRepresentation() as AnyObject,
      ["units": units.rawValue as AnyObject] as AnyObject,
    ]
    
    guard let distance = js?.call(withArguments: args)?.toDouble()
      else {
        assertionFailure()
        return .greatestFiniteMagnitude
    }
    return distance
  }
   
  // NOTE: we have `distance` imported in js as well but dont really need it so havent implemented it in Swift
  
  // MARK: Commented functions below are from original SwiftTurf repo and were also commented there, not sure whats up with that.

//	public static func union(feature: FeatureCollection) -> Polygon? {
//		
//		let unionFunction = sharedInstance.conttext.objectForKeyedSubscript("union")!
//		
//		let polygons = feature.features
//			.flatMap { $0 as? Polygon }
//			.flatMap { buffer($0, distance: 50, units: .Meters) }
//		
//		guard polygons.count != 0 else { return nil }
//		guard polygons.count >= 2 else { return polygons.first }
//		
//		var unionedPolygon = polygons.first
//
//		for (index, polygon) in polygons.enumerate() {
//			if index == 0 { continue }
//			let polygonsToUnion = [unionedPolygon!.geoJSONRepresentation(), polygon.geoJSONRepresentation()]
//			if let unionResult = unionFunction.callWithArguments(	polygonsToUnion)!.toDictionary() {
//				unionedPolygon = Polygon(dictionary: unionResult)
//			}
//		}
//		return unionedPolygon
//	}
	
//	public static func explode(feature: GeoJSONConvertible) -> FeatureCollection? {
//		
//		let explodeFunction = sharedInstance.conttext.objectForKeyedSubscript("explode")!
//		if let points = explodeFunction.callWithArguments([feature.geoJSONRepresentation()])?.toDictionary() {
//			return FeatureCollection(dictionary: points)
//		} else {
//			return nil
//		}
//	}
	
//	public static func concave(points: FeatureCollection, maxEdge: Int, units: Units) -> Polygon? {
//		
//		let concaveFunction = sharedInstance.conttext.objectForKeyedSubscript("concave")!
//		let result = concaveFunction.callWithArguments([points.geoJSONRepresentation(), maxEdge, units.rawValue])
//		
//		if let concave = result?.toDictionary() {
//			return Polygon(dictionary: concave)
//		} else {
//			return nil
//		}
//	}

//	public static func convex(points: FeatureCollection) -> Polygon? {
//		
//		let convexFunction = sharedInstance.conttext.objectForKeyedSubscript("convex")!
//		let result = convexFunction.callWithArguments([points.geoJSONRepresentation()])
//		
//		if let convex = result?.toDictionary() {
//			return Polygon(dictionary: convex)
//		} else {
//			return nil
//		}
//	}

//	public static func tesselate(feature: GeoJSONConvertible) -> FeatureCollection? {
//	
//		let tesselateFunction = sharedInstance.conttext.objectForKeyedSubscript("tesselate")!
//		let tesselatedPolygons = tesselateFunction.callWithArguments([feature.geoJSONRepresentation()])!
//		let geoJSON = tesselatedPolygons.toDictionary()!
//		let featureCollection = FeatureCollection(dictionary: geoJSON)
//		
//		return featureCollection
//	}
	
}
