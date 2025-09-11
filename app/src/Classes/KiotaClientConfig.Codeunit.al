namespace CABQR.Kiota.Client;

using CABQR.Kiota.Definitions;
using CABQR.Kiota.Utilities;
using System.Reflection;
using System.RestClient;

codeunit 72337301 "Kiota ClientConfig"
{
    var
        _RequestHelper: Codeunit "RequestHelper";
        _AuthenticationSet: Boolean;
        CustomHttpHandlerSet: Boolean;
        _CustomHeaders: Dictionary of [Text, Text];
        _QueryParameters: Dictionary of [Text, Text];
        _Authorization: Interface "Http Authentication";
        _Client: Interface "Kiota IApiClient";
        _HttpHandler: Interface "Http Client Handler";
        _BaseURL: Text;

    procedure BaseURL(URL: Text)
    begin
        this._BaseURL := URL;
    end;

    procedure BaseURL(): Text
    begin
        exit(this._BaseURL);
    end;

    procedure AppendBaseURL(Append: Text)
    begin
        if this._BaseURL = '' then
            this._BaseURL := Append
        else
            this._BaseURL := this._BaseURL + Append;
    end;

    procedure IsInitialized(): Boolean
    begin
        exit(this._AuthenticationSet);
    end;

    procedure Authorization(NewAuthorization: Interface "Http Authentication")
    begin
        this._Authorization := NewAuthorization;
        this._AuthenticationSet := true;
    end;

    procedure Authorization(): Interface "Http Authentication"
    var
        AuthorizationNotInitializedErr: Label 'Authorization not initialized.';
    begin
        if not this._AuthenticationSet then
            Error(AuthorizationNotInitializedErr);
        exit(this._Authorization);
    end;

    procedure Client(): Interface "Kiota IApiClient"
    begin
        exit(this._Client);
    end;

    procedure Client(NewApiClient: Interface "Kiota IApiClient")
    begin
        this._Client := NewApiClient;
    end;

    procedure AddHeader(HeaderName: Text; HeaderValue: Text)
    begin
        if not this._CustomHeaders.ContainsKey(HeaderName) then
            this._CustomHeaders.Add(HeaderName, HeaderValue)
        else
            this._CustomHeaders.Set(HeaderName, HeaderValue);
    end;

    procedure CustomHeaders(): Dictionary of [Text, Text]
    begin
        exit(this._CustomHeaders);
    end;

    procedure RequestHeaders(): Dictionary of [Text, Text]
    var
        NewHeaders: Dictionary of [Text, Text];
        HeaderName, HeaderValue : Text;
    begin
        foreach HeaderName in this._CustomHeaders.Keys() do begin
            HeaderValue := this._CustomHeaders.Get(HeaderName);
            if not this._RequestHelper.IsContentHeader(HeaderName) then
                NewHeaders.Add(HeaderName, HeaderValue);
        end;
        exit(NewHeaders);
    end;

    procedure ContentHeaders(): Dictionary of [Text, Text]
    var
        NewHeaders: Dictionary of [Text, Text];
        HeaderName, HeaderValue : Text;
    begin
        foreach HeaderName in this._CustomHeaders.Keys() do begin
            HeaderValue := this._CustomHeaders.Get(HeaderName);
            if this._RequestHelper.IsContentHeader(HeaderName) then
                NewHeaders.Add(HeaderName, HeaderValue);
        end;
        exit(NewHeaders);
    end;

    procedure AddQueryParameter(ParamName: Text; ParamValue: Text)
    begin
        if not this._QueryParameters.ContainsKey(ParamName) then
            this._QueryParameters.Add(ParamName, ParamValue)
        else
            this._QueryParameters.Set(ParamName, ParamValue);
    end;

    procedure BaseUrlWithParams(): Text
    var
        FirstParam: Boolean;
        EncodedValue: Text;
        FullUrl: Text;
        ParamName, ParamValue : Text;
    begin
        FullUrl := this._BaseURL;
        FirstParam := true;

        foreach ParamName in this._QueryParameters.Keys() do begin
            ParamValue := this._QueryParameters.Get(ParamName);
            EncodedValue := this.UrlEncode(ParamValue);
            if FirstParam then begin
                FullUrl += '?' + ParamName + '=' + EncodedValue;
                FirstParam := false;
            end else
                FullUrl += '&' + ParamName + '=' + EncodedValue;
        end;

        exit(FullUrl);
    end;

    local procedure UrlEncode(Value: Text): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.UriEscapeDataString(Value));
    end;

    internal procedure HttpHandler(): Interface "Http Client Handler"
    begin
        exit(this._HttpHandler);
    end;

    procedure HttpHandler(HttpHandlerImplementation: Interface "Http Client Handler")
    begin
        this._HttpHandler := HttpHandlerImplementation;
        this.CustomHttpHandlerSet := true;
    end;

    procedure HttpHandlerSet(): Boolean
    begin
        exit(this.CustomHttpHandlerSet);
    end;
}