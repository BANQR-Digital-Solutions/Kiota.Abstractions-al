namespace CABQR.Kiota.Client;

using CABQR.Kiota.Definitions;
using CABQR.Kiota.Utilities;
codeunit 72337302 "Kiota RequestHandler"
{
    var
        ClientConfig: Codeunit "Kiota ClientConfig";
        RequestHelper: Codeunit "RequestHelper";
        BodySet,
        RequestMsgSet : Boolean;
        Method: Enum System.RestClient."Http Method";
        Content: HttpContent;
        RequestMsg: HttpRequestMessage;
        BodyAsJson: JsonToken;

    procedure SetClientConfig(var NewClientConfig: Codeunit "Kiota ClientConfig")
    begin
        this.ClientConfig := NewClientConfig;
    end;

    procedure SetMethod(NewMethod: Enum System.RestClient."Http Method")
    begin
        this.Method := NewMethod;
    end;

    procedure SetBody(NewContent: HttpContent)
    begin
        this.Content := NewContent;
        this.BodySet := true;
    end;

    procedure SetBody(Objects: List of [Interface "Kiota IModelClass"])
    var
        Object: Interface "Kiota IModelClass";
        JsonArray: JsonArray;
        JsonAsText: Text;
    begin
        foreach Object in Objects do
            JsonArray.Add(Object.ToJson());
        JsonArray.WriteTo(JsonAsText);
        this.Content.WriteFrom(JsonAsText);
        this.BodySet := true;
    end;

    procedure SetBody(Object: Interface "Kiota IModelClass")
    var
        JsonAsText: Text;
    begin
        this.BodyAsJson := Object.ToJson().AsToken();
        this.BodyAsJson.WriteTo(JsonAsText);
        this.Content.WriteFrom(JsonAsText);
        this.BodySet := true;
    end;

    procedure SetBody(var NewReqMsg: HttpRequestMessage)
    begin
        this.RequestMsg := NewReqMsg;
        this.RequestMsgSet := true;
        this.BodySet := true;
    end;

    local procedure RequestMsgToCodeunitObject() msg: Codeunit System.RestClient."Http Request Message"
    begin
        msg.SetHttpRequestMessage(this.RequestMsg);
    end;

    procedure RequestMessage(): Codeunit System.RestClient."Http Request Message"
    var
        Headers: HttpHeaders;
    begin
        if this.RequestMsgSet then
            exit(this.RequestMsgToCodeunitObject());
        this.RequestMsg.Method := Format(this.Method);
        this.RequestMsg.SetRequestUri(this.ClientConfig.BaseUrlWithParams());
        if (this.ClientConfig.RequestHeaders().Count > 0) then begin
            this.RequestMsg.GetHeaders(Headers);
            this.RequestHelper.AddHeader(Headers, this.ClientConfig.RequestHeaders()); // Add custom headers
        end;
        if (this.BodySet) then begin
            this.RequestMsg.Content := this.Content;
            this.RequestMsg.Content.GetHeaders(Headers);
            this.RequestHelper.AddHeader(Headers, this.ClientConfig.ContentHeaders()); // Add custom headers
        end;
        exit(this.RequestMsgToCodeunitObject());
    end;

    procedure AddQueryParameter(ParamKey: Text; Value: Text)
    begin
        if (ParamKey = '') or (Value = '') then
            exit;
        this.ClientConfig.AddQueryParameter(ParamKey, Value);
    end;

    procedure AddQueryParameter(ParamKey: Text; Value: Boolean)
    var
        BooleanText: Text;
    begin
        if ParamKey = '' then
            exit;
        if Value then
            BooleanText := 'true'
        else
            BooleanText := 'false';
        this.ClientConfig.AddQueryParameter(ParamKey, BooleanText);
    end;

    procedure AddQueryParameter(ParamKey: Text; Value: Integer)
    begin
        this.ClientConfig.AddQueryParameter(ParamKey, Format(Value));
    end;

    procedure AddQueryParameter(ParamKey: Text; Value: Decimal)
    begin
        this.ClientConfig.AddQueryParameter(ParamKey, Format(Value));
    end;

    procedure AddQueryParameter(ParamKey: Text; Value: Date)
    begin
        this.ClientConfig.AddQueryParameter(ParamKey, Format(Value, 0, 9));
    end;

    procedure AddQueryParameter(ParamKey: Text; Value: DateTime)
    begin
        this.ClientConfig.AddQueryParameter(ParamKey, Format(Value, 0, 9));
    end;

    procedure AddQueryParameter(ParamKey: Text; Value: Time)
    begin
        this.ClientConfig.AddQueryParameter(ParamKey, Format(Value, 0, 9));
    end;

    procedure AddQueryParameter(ParamKey: Text; Values: List of [Text])
    var
        Value: Text;
        CombinedValue: Text;
        IsFirst: Boolean;
    begin
        if (ParamKey = '') or (Values.Count = 0) then
            exit;
        IsFirst := true;
        foreach Value in Values do begin
            if Value <> '' then begin
                if not IsFirst then
                    CombinedValue += ','
                else
                    IsFirst := false;
                CombinedValue += Value;
            end;
        end;
        if CombinedValue <> '' then
            this.ClientConfig.AddQueryParameter(ParamKey, CombinedValue);
    end;

    procedure HandleRequest()
    var
        RestClient: Codeunit System.RestClient."Rest Client";
        RqstMessage: Codeunit System.RestClient."Http Request Message";
        RspMessage: Codeunit System.RestClient."Http Response Message";
    begin
        if (this.ClientConfig.HttpHandlerSet()) then
            RestClient.Create(this.ClientConfig.HttpHandler())
        else
            RestClient.Create();
        RqstMessage := this.RequestMessage();
        RspMessage := RestClient.Send(RqstMessage);
        this.ClientConfig.Client().Response(RspMessage);
    end;
}