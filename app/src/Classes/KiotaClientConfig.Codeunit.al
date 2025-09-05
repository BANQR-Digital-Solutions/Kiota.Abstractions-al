namespace CABQR.Kiota.Client;

using CABQR.Kiota.Definitions;
using CABQR.Kiota.Utilities;

codeunit 72337301 "Kiota ClientConfig"
{
    var
        _Authorization: Codeunit "Kiota API Authorization";
        _RequestHelper: Codeunit "RequestHelper";
        _CustomHeaders: Dictionary of [Text, Text];
        _Client: Interface "Kiota IApiClient";
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
        exit(this._Authorization.IsInitialized());
    end;

    procedure Authorization(NewAuthorization: Codeunit "Kiota API Authorization")
    begin
        this._Authorization := NewAuthorization;
    end;

    procedure Authorization(): Codeunit "Kiota API Authorization"
    begin
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
}