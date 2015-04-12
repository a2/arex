public protocol MultiValueRepresentable {
    static var multiValueType: PropertyKind { get }

    var multiValueRepresentation: CFTypeRef { get }

    init?(multiValueRepresentation: CFTypeRef)
}
