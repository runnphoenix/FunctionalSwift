import Cocoa

// 公共设施
struct Position {
    var x:Double
    var y:Double
}

extension Position {
    func minus(position:Position) -> Position {
        return Position(x: x - position.x, y: y - position.y)
    }
    var length:Double {
        return sqrt(x*x + y*y)
    }
}

struct Ship {
    var position: Position
    var firingRange: Double
    var unsafeRange: Double
}

// 一般实现
extension Ship {
    func canSafelyEngageShip(target: Ship, friendly: Ship) -> Bool {
        let targetDistance = target.position.minus(position).length
        let friendlyDistance = friendly.position.minus(target.position).length
        return (targetDistance <= firingRange)
            && (targetDistance > unsafeRange)
            && (friendlyDistance > friendly.unsafeRange)
    }
}


// 函数式实现
typealias Region = Position -> Bool

func circle(radius:Double) -> Region {
    return { (point:Position) in
        point.length < radius
    }
}

func shift(region:Region, offset:Position) -> Region {
    return { (point:Position) in
        region(point.minus(offset))
    }
}

func invert(region: Region) -> Region {
    return { point in !region(point) }
}

func interSection(region1:Region, region2:Region) -> Region {
    return { point in region1(point) && region2(point) }
}

func difference(region: Region, minus: Region) -> Region {
    return interSection(region, region2: invert(minus))
}

extension Ship {
    func canSafelyEngageShipFunctional(target: Ship, friendly: Ship) -> Bool {
        let rangeRegion = difference(circle(firingRange), minus: circle(unsafeRange))
        let firingRegion = shift(rangeRegion, offset: position)
        let friendlyRegion = shift(circle(friendly.unsafeRange), offset: friendly.position)
        let resultRegion = difference(firingRegion, minus: friendlyRegion)
        return resultRegion(target.position)
    }
}
