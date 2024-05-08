$version: "2"

namespace dev.stelo.foxbat

@length(min: 1)
string NonEmptyString

@httpError(400)
@error("client")
@documentation("Exception indicating bad request for the operation.")
structure BadRequestException with [BaseException] {
    message: NonEmptyString
}

@httpError(401)
@error("client")
@documentation("Exception indicating missing or bad authentication for the operation.")
structure NotAuthorizedException with [BaseException] {
    message: NonEmptyString
}

@httpError(403)
@error("client")
@documentation("Exception indicating access is denied for the operation.")
structure ForbiddenException with [BaseException] {
    message: NonEmptyString
}

@httpError(404)
@error("client")
@documentation("Exception indicating resource is not found.")
structure NotFoundException with [BaseException] {
    message: NonEmptyString
}

@httpError(415)
@error("client")
@documentation("Exception indicating unsupported media type.")
structure NotSupportedException with [BaseException] {
    message: NonEmptyString
}

@httpError(422)
@error("client")
@retryable
@documentation("Exception indicating that server will not be able to process the request.")
structure UnprocessableContentException with [BaseException] {
    message: NonEmptyString
}

@httpError(429)
@error("client")
@retryable
@documentation("Exception indicating that rate limit has been breached for a particular operation.")
structure ThrottledException with [BaseException] {
    message: NonEmptyString
}

@httpError(500)
@error("server")
@retryable
@documentation("Exception to indicate a dependency error for the operation.")
structure DependencyException with [BaseException] {
    message: NonEmptyString
}

@httpError(500)
@error("server")
@documentation("Exception to indicate an internal service failure.")
structure InternalServerErrorException with [BaseException] {
    message: NonEmptyString
}

@httpError(503)
@error("server")
@retryable
@documentation("Exception to indicate the service is unavailable.")
structure ServiceUnavailableException with [BaseException] {
    message: NonEmptyString
}

@httpError(504)
@error("server")
@retryable
@documentation("Exception to indicate a timeout for the operation.")
structure ServerTimeoutException with [BaseException] {
    message: NonEmptyString
}

@mixin
structure BaseException {
    @httpHeader("x-amzn-ErrorType")
    errorType: String

    @httpHeader("Access-Control-Allow-Headers")
    allowHeaders: String
}

@mixin
operation BaseOperationErrors {
    errors: [
        BadRequestException
        NotAuthorizedException
        ForbiddenException
        NotFoundException
        NotSupportedException
        UnprocessableContentException
        ThrottledException
        DependencyException
        InternalServerErrorException
        ServiceUnavailableException
        ServerTimeoutException
    ]
}
