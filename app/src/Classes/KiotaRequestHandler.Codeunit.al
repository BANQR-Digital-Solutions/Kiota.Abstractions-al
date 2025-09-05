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
        this.RequestMsg.SetRequestUri(this.ClientConfig.BaseUrl());
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

    procedure HandleRequest()
    var
        RestClient: Codeunit System.RestClient."Rest Client";
        RqstMessage: Codeunit System.RestClient."Http Request Message";
        RspMessage: Codeunit System.RestClient."Http Response Message";
    begin
        RqstMessage := this.RequestMessage();
        RspMessage := RestClient.Send(RqstMessage);
        this.ClientConfig.Client().Response(RspMessage);
    end;
}