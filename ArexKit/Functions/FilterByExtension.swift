import Foundation

/**
    Filters an array of URLs based on filename extension.

    :param: URLs An array of URLs to filter.
    :param: extensions A set of filename extensions. The extensions should not include the dot (".") character.

    :returns: An array of all input URLs whose path extension is contained in the specified list.
*/
public func filterByExtension(URLs: [NSURL], extensions: Set<String>) -> [NSURL] {
    return URLs.filter { URL in
        map(URL.pathExtension) { extensions.contains($0) } ?? false
    }
}

/**
    Filters a sequence of URLs based on filename extension.

    :param: URLs A sequence of URLs to filter.
    :param: extensions A sequence of filename extensions. The extensions should not include the dot (".") character.

    :returns: An array of all input URLs whose path extension is contained in the specified list.
*/
public func filterByExtension<T: SequenceType, U: SequenceType where T.Generator.Element == NSURL, U.Generator.Element == String>(URLs: T, extensions: U) -> [NSURL] {
    return filter(URLs) { URL in
        return URL.pathExtension.map { contains(extensions, $0) } ?? false
    }
}

/**
    Filters an array of paths based on filename extension.

    :param: paths An array of paths to filter.
    :param: extensions An array of filename extensions. The extensions should not include the dot (".") character.

    :returns: An array of all input paths whose path extension is contained in the specified list.
*/
public func filterByExtension(paths: [String], extensions: Set<String>) -> [String] {
    return paths.filter { path in extensions.contains(path.pathExtension) }
}

/**
    Filters a sequence of paths based on filename extension.

    :param: paths A sequence of paths to filter.
    :param: extensions A sequence of filename extensions. The extensions should not include the dot (".") character.

    :returns: An array of all input paths whose path extension is contained in the specified list.
*/
public func filterByExtension<T: SequenceType, U: SequenceType where T.Generator.Element == String, U.Generator.Element == String>(paths: T, extensions: U) -> [String] {
    return filter(paths) { path in
        contains(extensions, path.pathExtension)
    }
}
