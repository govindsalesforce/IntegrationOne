@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        // System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        Pattern regExPattValueOfKeyNamedPassword = Pattern.compile('(?<=password\\=)([^&]+)');
        Matcher regExMatchValueOfKeyNamedPassword = regExPattValueOfKeyNamedPassword.matcher(req.getBody());
        system.debug(req.getBody());
        
        HttpResponse res = new HttpResponse();
        
        if (req.getBody().right(23).equals('=TheCorrectTestPassword')) {
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id":"ThisIsNotANullResponse"}');
            res.setStatusCode(200);         
        } else {
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"somethingOtheThanId":"ThisIsNotANullResponse"}');
            res.setStatusCode(200);
        }
        
        return res;
    }
}