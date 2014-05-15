package com.kpm.common
{
	import com.kpm.kpm.DriverData;
    import flash.net.URLVariables;
    import flash.net.URLRequest;
    import flash.net.URLLoader;
    import flash.events.IOErrorEvent;
    import flash.net.URLRequestMethod;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
    import flash.net.URLLoaderDataFormat;



	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	public class KpmFtp extends EventDispatcher
	{
		private var s 					: Socket;
		private var server				: String = DriverData.FTP_SERVER;
		private var user 				: String = DriverData.FTP_USER;
		private var password 			: String = DriverData.FTP_PASSWORD;

        // create a URLLoader to POST data to the server
        var loader:URLLoader = new URLLoader();
        // server address where your script is listening
        var request:URLRequest = new URLRequest("http://example.com");

		private var fileSize			: uint;
		private var fileContents		: ByteArray ;
		private var dataChannelSocket	: Socket;
		private var ftpResponse			: String;	
		private  var dataResponse		:String;
		private var currentPathName		: String;
		private var currentFileName 	: String;
		private var streamToWrite 		: String;
		private var download			: Boolean;
		private var actionInProgress	: Boolean;
		private var downloadedFile		: KpmIO;
        private var bubbleLogId            : int;
		
		//will hold the IP address of new socket created by FTP
		private    var dataChannelIP:String;
		//will hold the Port number created by FTP
		private    var dataChannelPort:int;
        private var binaryMode : Boolean = false;

        var sqlBubbleLoader, sqlTaskLoader :URLLoader
        var urlParams : URLVariables;
		
		public function KpmFtp()
		{
		}


		public function uploadToFtp(pServer : String, pPath : String, pFileName : String, pStream : *, pBinaryMode : Boolean = false):void
		{
			if(actionInProgress)
				Util.debug("action in progress cant upload", this);

            currentPathName = pPath;
			currentFileName = pFileName;
			download = false;

            binaryMode = pBinaryMode;

			if(pStream is XML)
				streamToWrite = pStream.toXMLString();
			else
				streamToWrite = pStream;

            if(binaryMode)
            {
                fileContents = pStream;
                fileSize = pStream.length;
            }
            else
            {
                fileContents = new ByteArray;
                fileContents.writeUTFBytes(streamToWrite);
                fileSize = streamToWrite.length;
                Util.debug(streamToWrite, this);

            }


            Util.debug("uploading", this);
			Util.debug(pPath + " " + pFileName, this);

			
			createSocket();			
		}
		
		public function downloadFromFtp(pServer : String, pPath : String, pFileName : String):void
		{
			if(actionInProgress)
				Util.debug("action in progress cant download", this);
				
			currentPathName = pPath;
			currentFileName = pFileName;
			download = true;
			
			Util.debug("downloading", this);
			Util.debug(pPath + " " + pFileName, this);
			Util.debug(streamToWrite, this);
			
			createSocket();
		}
		
		private function createSocket()
		{
			s = new Socket(server, 21);
			actionInProgress = true;
			s.addEventListener(ProgressEvent.SOCKET_DATA, receiveReply, false, 0 , true);
			s.addEventListener(IOErrorEvent.IO_ERROR, showError, false, 0 , true);
			s.addEventListener(SecurityErrorEvent.SECURITY_ERROR, showSecError, false, 0 , true);
			s.addEventListener(Event.CONNECT,onSocketConnect, false, 0 , true);
			s.addEventListener(Event.CLOSE,onSocketClose, false, 0 , true);
			s.addEventListener(Event.ACTIVATE,onSocketActivate, false, 0 , true);

		}
		
		private function onSocketConnect(evt:Event):void {
			//createRemoteFile(DriverData.FTP_PATH, "log.txt");
			Util.debug("OnSocketConnect–>"+evt.target.toString(), this);
		}
		private function onSocketClose(evt:Event):void {
			Util.debug("onSocketClose–>"+evt.target.toString(), this);
		}
		private function onSocketActivate(evt:Event):void {
			Util.debug("onSocketActivate–>"+evt.target.toString(), this);
		}
		

		
		private function createRemoteFile(pFileName:String):void
		{
			if(pFileName !=null && pFileName !="")
			{
				s.writeUTFBytes("STOR "+pFileName+"\n");
				s.flush();
			}
		}

		private function receiveReply(e:ProgressEvent):void
		{
			ftpResponse = s.readUTFBytes(s.bytesAvailable);
			var serverResponse:Number = Number(ftpResponse.substr(0, 3));
			
			
			//few FTP Responce Codes
			switch(serverResponse){
				
				case 220 :
					//FTP Server ready responce
					sendCommand("USER " + user);
					break;
				
				case 331 :
					//User name okay, need password
					sendCommand("PASS " + password);
					//sendCommand("OPTS UTF8 ON");
					break;
				
				case 230:
					//User logged in
					//if you want to change the directory for upload file
					sendCommand("CWD " + currentPathName); 
					break;
					
				case 250 :
					sendCommand("PASV");
                    sendCommand("TYPE I");
					break;
				
				case 227 :
					//Entering Passive Mode (h1,h2,h3,h4,p1,p2).
					//get the ip from the string response... this lets us set up our data connection...
					
					if(!dataChannelSocket)
						createPassiveSocket(ftpResponse);
					break;
					
				case 150:
					if(!download)
						uploadData();
						
					break;
				
				case 226 :
					if(download)
						onDataReceived();
					else 
						onDataSent();
					break;
					
				default :
					Util.debug("command not handled", this);
					
					
			}
			
			Util.debug(ftpResponse,this);
		}
		
		private function createPassiveSocket(pFtpResponse : String)
		{
			var temp:Object = pFtpResponse.substring(pFtpResponse.indexOf("(")+1,pFtpResponse.indexOf(")"));
			var dataChannelSocket_temp:Object = temp.split(",");
			dataChannelIP = dataChannelSocket_temp.slice(0,4).join(".");
			dataChannelPort = parseInt(dataChannelSocket_temp[4])*256 + int(dataChannelSocket_temp[5]);
			//create new Data Socket based on dataChannelSocket and dataChannelSocket port
			Util.debug("ip port " + dataChannelIP + " " + dataChannelPort, this);
			dataChannelSocket = new Socket(dataChannelIP, dataChannelPort);
			
			if(download)
			{
				dataChannelSocket.addEventListener(Event.CONNECT, onDownloadDataSocketConnect, false, 0 , true);
			}
			else
			{
				createRemoteFile(currentFileName);
				dataChannelSocket.addEventListener(Event.CONNECT, onUploadDataSocketConnect, false, 0 , true);
			}
			
			dataChannelSocket.addEventListener(ProgressEvent.SOCKET_DATA, receiveData, false, 0 , true);
			dataChannelSocket.addEventListener(ProgressEvent.PROGRESS, progressHandler2, false, 0 , true);
		} 
		
		private function onDownloadDataSocketConnect(evt:Event):void 
		{
			Util.debug("download socket connect", this);
			sendCommand("RETR " + currentFileName);
			
			
		} 
		
		private function onDataReceived()
		{
			Util.debug("downloading data ",this);
			fileContents = new ByteArray;
			var string : String = dataChannelSocket.readUTFBytes(5);
			Util.debug(string, this);
			
			//dataChannelSocket.flush();
			//dataChannelSocket.close();
			
		}
		
				
		private function uploadData():void
		{

            Util.debug("pFile " + fileContents + " " + fileSize, this);
			dataChannelSocket.writeBytes(fileContents,0,fileSize);
			//this.dispatchEvent(new Event(DriverData.CLOSE_APP))
			
		}
		
		
		private function onUploadDataSocketConnect(evt:Event):void {
			//createRemoteFile(DriverData.FTP_PATH, "log.txt");
			Util.debug("OnDataSocketConnect–>"+evt.target.toString(), this);
		}
		
		private function receiveData(e:ProgressEvent):void{
			dataResponse = dataChannelSocket.readUTFBytes(dataChannelSocket.bytesAvailable);
			Util.debug("dataChannelSocket_response—>" + dataResponse, this);
			Util.debug("e.bytesLoaded:["+e.bytesLoaded+"], e.bytesTotal:["+e.bytesTotal+"]", this);
		}	 
		
		private function onDataSent()
		{
			this.dispatchEvent(new Event(DriverData.DATA_SENT));
            dataChannelSocket.flush();
            actionInProgress = false;

        }
		
		private function progressHandler2(e:ProgressEvent):void 
		{
			Util.debug("e.bytesLoaded:["+e.bytesLoaded+"], e.bytesTotal:["+e.bytesTotal+"]", this);
		}
		
		function showError(e:IOErrorEvent):void{
			Util.debug(e, this);
			this.dispatchEvent(new Event(DriverData.NO_INTERNET));
		}
		
				
		private function showSecError(e:SecurityErrorEvent):void
		{
      		Util.debug("SecurityError–>"+e.text, this);
      		this.dispatchEvent(new Event(DriverData.NO_INTERNET));
      		
		} 
		
		private function sendCommand(arg:String):void {
			arg +="\n";
			s.writeUTFBytes(arg);
			s.flush();
		}

        public function uploadTaskLogToDB(pServerPath : String, pBubbleXML : XML) : void {
            Util.debug("KpmFtp.uploadTaskLogToDB " + pServerPath + "uploadInsidebbLogtoDB.php");

            // create a URLLoader to POST data to the server
            sqlTaskLoader = new URLLoader();

            var request:URLRequest = new URLRequest("http://kidsplaymath.org/data/uploadInsidebbLogtoDB.php");

            var i=0;
            for each (var mychildtag:XML in pBubbleXML.task)
            {
                Util.debug(mychildtag.name());
                Util.debug(mychildtag.@success);

                //if the xml children is a task
                if(mychildtag.@success)
                {
                    //addding foreign keys.
                    mychildtag.@BBLogID = pBubbleXML.@BBLogId;

                    for each(var grandchildtag :XML in mychildtag.failed)
                    {
                        Util.debug(grandchildtag.name());
                        Util.debug(grandchildtag.@currentMove);

                        grandchildtag.@TaskLogID = mychildtag.@TaskID;

                    }
                }
                i++;

            }

        }


        public function uploadBBLogToDB(pServerPath : String, pBubbleXML : XML) : void {
            Util.debug("KpmFtp.uploadBBLogToDB" + pServerPath + "uploadbbLogToDB.php");

            // create a URLLoader to POST data to the server
            sqlBubbleLoader = new URLLoader();
            urlParams = new URLVariables();
            // server address where your script is listening

            var request:URLRequest = new URLRequest("http://kidsplaymath.org/data/uploadbbLogToDB.php");
            //request.contentType = "text/xml";
            //request.data = pBubbleXML.toXMLString();

//            var params:URLVariables = new URLVariables();

            uploadTaskLogToDB(pServerPath, pBubbleXML)
            urlParams.data = pBubbleXML.toXMLString();

            request.data = urlParams;

            // set the request type to POST as it's more secure and can hold more data
            request.method = URLRequestMethod.POST;

            try
            {
                sqlBubbleLoader.load(request);
            }
            catch(error : Error)
            {
                DriverData.logTool.reportError("Post Failed \n " + pBubbleXML.toXMLString(), false);
                DriverData.Driver.notifyInternet(false);
            }

            sqlBubbleLoader.addEventListener(Event.COMPLETE, onUploadbbLogComplete);
            sqlBubbleLoader.addEventListener(IOErrorEvent.IO_ERROR, onPostFailed);
            sqlBubbleLoader.dataFormat = URLLoaderDataFormat.TEXT;
        }



        function onPostFailed(e:Event):void
        {
            // happens if the server is unreachable
            DriverData.logTool.reportError("Post Failed \n " + e.target.data + " \n" , false);
            DriverData.Driver.notifyInternet(false);
            trace("I/O Error when sending a POST request");
        }

        function onPostComplete(e:Event):void
        {
            // loader.data will hold the response received from the server
            trace("Luuu " + sqlBubbleLoader.data + " luuu");

        }

        function onUploadbbLogComplete(e : Event) : void
        {
            trace("PostComplete");
            trace("Luuu " + sqlBubbleLoader.data + " luuu");
            //DriverData.logTool.uploadTaskLogToDB();
        }

	}
}