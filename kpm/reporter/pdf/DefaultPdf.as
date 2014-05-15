package com.kpm.reporter.pdf{
	
	import cmodule.as3_jpeg_wrapper.CLibInit;

import com.as3collections.ArrayQueue;
import com.coltware.airxmail.MimeTextPart;
import com.coltware.airxmail.smtp.SMTPEvent;
import com.kpm.common.KpmIO;
import com.kpm.common.Util;
import com.kpm.kpm.DriverData;
    import com.kpm.ui.UIGod;
    import com.kpm.common.KpmFtp;
import com.hurlant.crypto.tls.TLSSocket;

import flash.display.DisplayObject;
	import flash.display.Sprite;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.geom.Rectangle;
import flash.net.Socket;
import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	import flash.filesystem.FileStream;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.system.Capabilities;
    import flash.media.StageWebView;

	import com.coltware.airxmail.INetAddress;
	import com.coltware.airxmail.MailSender.SMTPSender;
	import com.coltware.airxmail.MimeMessage;
	import com.coltware.airxmail.RecipientType;
    import com.coltware.airxmail.MimeBinaryPart;
    import com.coltware.airxmail.ContentType;

	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.PdfViewPreferences;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	import org.purepdf.resources.BuiltinFonts;	
	import flash.utils.Dictionary;

	public class DefaultPdf extends Sprite
	{		
		public var document: PdfDocument;
		protected var writer: PdfWriter;				
		internal var buffer: ByteArray;
        private var reportFtp : KpmFtp;

        protected var sender:SMTPSender;
        protected var tls : TLSSocket;

		protected var embedFonts : Object;
		protected var embedFontsData:Dictionary = null;
		protected var fontLoader:FontLoader;
        private var reportFile : File;
        private var fsFtp : FileStream;
        private var bytesFtp : ByteArray;
        private var emailTo : String;
        private var kidName : String;
						
		public function DefaultPdf(embedFontsData:Dictionary, d_list: Array = null)
		{
			super();			
			this.embedFontsData = embedFontsData;
			this.embedFonts = new Object();
			this.registerFonts();
			this.createDocument();
		}
		
		/**
		Metodo publico que carga un arreglo con la informacion de las fuentes embebidas.
		**/
		public function setEmbededFonts():void{
			var i:int = 0;
			
			for each (var f: Object in this.embedFontsData){		
				FontsResourceFactory.getInstance().registerFont(f[0]+"." +f[1],f[2]);				
				var bf : BaseFont = BaseFont.createFont(f[0]+"." +f[1],BaseFont.WINANSI,BaseFont.EMBEDDED);
				embedFonts[i] = [f[0],bf];
				i++;
			}												
		}		
		
		/**
		Metodo protegido que registra las fuentes para que luego puedan ser usadas en el pdf.
		**/
		protected function registerFonts(): void
		{
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA, new BuiltinFonts.HELVETICA());
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA_BOLD, new BuiltinFonts.HELVETICA_BOLD());
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA_OBLIQUE, new BuiltinFonts.HELVETICA_OBLIQUE());
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA_BOLDOBLIQUE, new BuiltinFonts.HELVETICA_BOLDOBLIQUE());
			FontsResourceFactory.getInstance().registerFont( BaseFont.COURIER, new BuiltinFonts.COURIER());
			FontsResourceFactory.getInstance().registerFont( BaseFont.COURIER_BOLD, new BuiltinFonts.COURIER_BOLD());
			FontsResourceFactory.getInstance().registerFont( BaseFont.COURIER_OBLIQUE, new BuiltinFonts.COURIER_OBLIQUE());
			FontsResourceFactory.getInstance().registerFont( BaseFont.COURIER_BOLDOBLIQUE, new BuiltinFonts.COURIER_BOLDOBLIQUE());
			FontsResourceFactory.getInstance().registerFont( BaseFont.TIMES_ROMAN, new BuiltinFonts.TIMES_ROMAN());
			FontsResourceFactory.getInstance().registerFont( BaseFont.TIMES_BOLD, new BuiltinFonts.TIMES_BOLD());	
			FontsResourceFactory.getInstance().registerFont( BaseFont.TIMES_ITALIC, new BuiltinFonts.TIMES_ITALIC());	
			FontsResourceFactory.getInstance().registerFont( BaseFont.TIMES_BOLDITALIC, new BuiltinFonts.TIMES_BOLDITALIC());
			this.setEmbededFonts();						
		}	
		
		/**
		Metodo protegido que permite crear el documento pdf.
		**/
		protected function createDocument( subject: String=null, rect: RectangleElement=null ): void
		{
			buffer = new ByteArray();

			if ( rect == null )
				rect = PageSize.A4;

			writer = PdfWriter.create( buffer, rect );
			document = writer.pdfDocument;
			document.addAuthor( "KidsPlayMath" );
			document.addTitle( getQualifiedClassName( this ) );
			if( subject ) 
				document.addSubject( subject );
			document.setViewerPreferences(PdfViewPreferences.FitWindow);
			document.open();

		}	
		
		public function save(absoluteFileName:String, openDocument:Boolean = false, pEmail : String = "", pKidName : String = ""){
			var fs:FileStream = new FileStream();			
			reportFile = new File(absoluteFileName);

			fs.open(reportFile, FileMode.WRITE);
			this.document.close();
			var pdfBytes:ByteArray = this.buffer;
			fs.writeBytes(pdfBytes);
			trace("DefaultPdf, The document " + absoluteFileName + " was generated successfully.");
            trace("email is " + pEmail);
            fs.close();

            emailTo = pEmail;
            kidName = pKidName ;
            fsFtp  = new FileStream();
            bytesFtp = new ByteArray();

            fsFtp.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            fsFtp.addEventListener(Event.COMPLETE, readComplete);
            fsFtp.openAsync(reportFile, FileMode.READ);


            if(openDocument)
            {
                if(DriverData.Driver.iOS || DriverData.Driver.Android)
                {
                    var wb = new StageWebView();
                    wb.stage = DriverData.Driver.stage;
                    wb.viewPort = new Rectangle(10,0,1200,760);//specify the clipping mask(x,y,w,h)
                    wb.loadURL( absoluteFileName );

                    UIGod.webviews.enqueue(wb);

                }
                else
                {
                    reportFile.openWithDefaultApplication();
                }






            }
		}

        function progressHandler(event:ProgressEvent):void
        {
            fsFtp.readBytes(bytesFtp, fsFtp.position, fsFtp.bytesAvailable);
            trace("DefaultPdf.progressHandler " + fsFtp.position + " " +    fsFtp.bytesAvailable)
        }


        public function readComplete(e : Event)
        {
            trace("defaultPdf.finished reading" + bytesFtp.length);
            reportFtp = new KpmFtp();
            //reportFtp.uploadToFtp(DriverData.FTP_SERVER, DriverData.FTP_REPORT_PATH, reportFile.name, bytesFtp, true);
            //reportFtp .addEventListener(DriverData.DATA_SENT, fileUploaded);

            if(emailTo)
                send_email( bytesFtp, emailTo);



        }


        private function send_email(pAttachment : ByteArray, emailTo : String):void{
           trace("DefaultPdf.send_email")
           //  How to send plain text email

           sender = new SMTPSender();
           sender.setParameter(SMTPSender.HOST,"smtp.gmail.com");
           sender.setParameter(SMTPSender.PORT,465);  // default port is 25
           // If you use SMTP-AUTH
           sender.setParameter(SMTPSender.AUTH,true);
           sender.setParameter(SMTPSender.CONNECTION_TIMEOUT,50000);
           sender.setParameter(SMTPSender.USERNAME,"carlara@gmail.com");
           sender.setParameter(SMTPSender.PASSWORD,"Eno0208.");

            sender.addEventListener(SMTPEvent.SMTP_AUTH_NG, eventHandler);
            sender.addEventListener(SMTPEvent.SMTP_AUTH_OK, eventHandler);
            sender.addEventListener(SMTPEvent.SMTP_COMMAND_ERROR, eventHandler);
            sender.addEventListener(SMTPEvent.SMTP_CONNECTION_FAILED, eventHandler);
            sender.addEventListener(SMTPEvent.SMTP_SENT_OK, eventHandler);
            sender.addEventListener(SMTPEvent.SMTP_START_TLS, eventHandler);

            sender.addEventListener(SMTPEvent.SMTP_START_TLS, startTlsHandler);
            tls = new TLSSocket();
            sender.setParameter(SMTPSender.SOCKET_OBJECT,tls);

            // Create email message
            var message:MimeMessage = new MimeMessage();
            var contentType:ContentType = ContentType.MULTIPART_MIXED;
            message.contentType = contentType;

            //  Set from email address and reciepients
            var from:INetAddress = new INetAddress("support@kidsplaymath.org","Kids Play Math");
            message.setFrom(from);

            var toRecpt:INetAddress = new INetAddress(emailTo, "To");
            var toRecpt2:INetAddress = new INetAddress("carlara@gmail.com","Carlos Lara Lead Programmer");
            message.addRcpt(RecipientType.TO,toRecpt);
            message.addRcpt(RecipientType.TO,toRecpt2);

            var subject : String = "";
            subject += ""
            message.setSubject("Kidsplaymath Progress Report");

            //  Plain Text Part
            var textPart:MimeTextPart = new MimeTextPart();
            textPart.contentType.setParameter("charset","UTF-8");
            textPart.transferEncoding = "8bit";

            if(reportFile.name.indexOf("Combined") != -1)
                textPart.setText("Attached is the Combined KidsplayMath Report requested");
            else
                textPart.setText("Attached is the KidsplayMath " + (reportFile.name.indexOf("_f_") ? "Family" : "Teacher") + "Report for " + kidName);

            message.addChildPart(textPart);

            // file attachment
            var filePart:MimeBinaryPart = new MimeBinaryPart();
            filePart.setAttachementStream(pAttachment, reportFile.name);
            filePart.contentType.setMainType("application");
            filePart.contentType.setSubType("pdf");

            message.addChildPart(filePart);


            trace("message " + message);
            trace("message " + message.attachmentChildren);
            trace("message " + message.getRecipients(RecipientType.TO));
            sender.send(message);
            sender.close();

        }

        protected function eventHandler(e:Event):void {
            Util.debug("Received event from SMTPSender: " + e.toString());

        }


        public function startTlsHandler(event:SMTPEvent):void{
			var sock:Socket = event.socket as Socket;
			tls.startTLS(sock,"smtp.gmail.com");
        }


        public function fileUploaded(e : Event)
        {
            trace("DefaultPdf.fileUploaded");
        }


		
		public function pageBreak(){
			this.document.newPage();
		}
	}
}