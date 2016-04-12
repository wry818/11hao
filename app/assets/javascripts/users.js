Raisy.users = {
    minilogo_data_cropper:{ischage:false,x:0,y:0,height:0,width:0, scaleX:0,scaleY:0,filename:""},
  init: function() {
    var _this = this;
		
		$("#seller_signup_selector_continue").click(function(){
			var acc_type=$("#user_account_type").val();
			
			switch (acc_type) {
				case "1":
					$(".seller_signup_section").hide();
					$("#seller_name_section").show();
					$("#seller_step_tips_modal .modal-body").html($("#seller_step_tips_18_1").html());
					
					if (Raisy.users.show_seller_step_tips)
						$("#seller_step_tips_modal").modal("show");
						
					break;
					
				case "2":
					$(".parent-info-14").show();
					$(".parent-info-13").hide();
					$(".seller_signup_section").hide();
					$("#seller_parent_info_section").show();
					$("#seller_step_tips_modal .modal-body").html($("#seller_step_tips_14_1").html());
					
					if (Raisy.users.show_seller_step_tips)
						$("#seller_step_tips_modal").modal("show");
						
					break;
					
				case "3":
					$(".parent-info-13").show();
					$(".parent-info-14").hide();
					$(".seller_signup_section").hide();
					$("#seller_parent_info_section").show();
					$("#seller_step_tips_modal .modal-body").html($("#seller_step_tips_13_1").html());
					
					if (Raisy.users.show_seller_step_tips)
						$("#seller_step_tips_modal").modal("show");
						
					break;
			}
		});
		
		$("#signup .seller-back-btn").click(function() {
			var currentstep=$(this).data("currentstep");
			var acc_type=$("#user_account_type").val();
			
			switch (currentstep) {
				case "2-13-14":
				case "2-18":
					$(".seller_signup_section").hide();
					$("#seller_signup_selector").show();
					$("#seller_step_tips_modal .modal-body").html($("#seller_step_tips_selector").html());
					
					if (Raisy.users.show_seller_step_tips)
						$("#seller_step_tips_modal").modal("show");
						
					break;
					
				case "3-13-14":
					$(".seller_signup_section").hide();
					$("#seller_parent_info_section").show();
					
					if (acc_type=="2") 
						$("#seller_step_tips_modal .modal-body").html($("#seller_step_tips_14_1").html());
						
					if (acc_type=="3") 
						$("#seller_step_tips_modal .modal-body").html($("#seller_step_tips_13_1").html());
						
					if (Raisy.users.show_seller_step_tips)
						$("#seller_step_tips_modal").modal("show");
						
					break;
					
				case 4:
					if (acc_type=="1")  {
						$(".seller_signup_section").hide();
						$("#seller_name_section").show();
						
						$("#seller_step_tips_modal .modal-body").html($("#seller_step_tips_18_1").html());
					}
					else {
						$(".seller_signup_section").hide();
						$("#seller_child_section").show();
						
						if (acc_type=="2") 
							$("#seller_step_tips_modal .modal-body").html($("#seller_step_tips_14_2").html());
						
						if (acc_type=="3") 
							$("#seller_step_tips_modal .modal-body").html($("#seller_step_tips_13_2").html());
					}
					
					if (Raisy.users.show_seller_step_tips)
						$("#seller_step_tips_modal").modal("show");
											
					break;
			}
		});
		
		$("#signup .seller-continue-btn").click(function() {
			if (!$("#signup_form").valid()) return;
			
			var currentstep=$(this).data("currentstep");
			var acc_type=$("#user_account_type").val();
			
			switch (currentstep) {
				case "2-13-14":
					$(".seller_signup_section").hide();
					$("#seller_child_section").show();
					
					if (acc_type=="2") 
						$("#seller_step_tips_modal .modal-body").html($("#seller_step_tips_14_2").html());
						
					if (acc_type=="3") 
						$("#seller_step_tips_modal .modal-body").html($("#seller_step_tips_13_2").html());
						
					if (Raisy.users.show_seller_step_tips)
						$("#seller_step_tips_modal").modal("show");
					
					break;
					
				case "2-18":
					$(".seller_signup_section").hide();
					$("#seller_account_section").show();
					break;
					
				case "3-13-14":
					$(".seller_signup_section").hide();
					$("#seller_account_section").show();
					break;
					
				case 4:
					break;
			}
		});
		
		$("#signup .cloudinary-fileupload").off("cloudinarydone").on("cloudinarydone", function (e, data) {
	        $(".status").text("");
	        $(".progress").not(".camp-photo-progress").hide().find(".progress-bar").css("width", "0").find('span').text("");
	        $("#drop-zone").css("border-color", "#ccc");
	        var params = {
	            format: data.result.format,
	            width: 100,
	            height: 100,
	            crop: "limit",
				angle: "exif"
	        };
	        var html = $.cloudinary.image(data.result.public_id, params);
	        $(".preview img").fadeOut(200, function() {
	            $('.preview').html(html);
	        }).fadeIn(200);
	    });
		
		$("#signup .upload_video").off("cloudinarydone").on("cloudinarydone", function (e, data) {
			
	        $(".status").text("");
	        $(".progress").not(".camp-photo-progress").hide().find(".progress-bar").css("width", "0").find('span').text("");
	        $("#drop-zone").css("border-color", "#ccc");
			
	        var params = {
	            width: "100%",
	            height: 240,
				background: "black",
				controls: true,
				preload: "auto",
				autobuffer: "autobuffer"
				// autoplay: true,
	        };
			
			$("#seller_video_file").val(data.result.public_id);
	        var html = $.cloudinary.video(data.result.public_id, params);

	        $(".preview video").fadeOut(200, function() {
	            $('.preview').html(html);
	        }).fadeIn(200);
			
	    });
		
		$("#contacts-show .contact-edit-btn").click(function(){
			Raisy.users.editContactClick(this);
		});
		
		$("#contacts-show .contact-save-btn").click(function(){
			Raisy.users.updateContactClick(this);
		});
		
		$("#contacts-show .contact-cancel-btn").click(function(){
			Raisy.users.cancelContactClick(this);
		});
		
		$("#contacts-show .contact-del-btn").click(function(){
			Raisy.users.deleteContactClick(this);
		});
		
		$("#contacts-show .seller-step-qa-icon").click(function(){
			$("#seller_step_tips_modal").modal("show");
		});
		
		$("#contacts-show #hide_seller_step_tips").off("click").on("click", function() {
			Raisy.users.show_seller_step_tips = false;
			
			$.ajax('/ajax/sellersteppopup', {
				type: 'GET',
				cache: false,
				data: { popup: "disable" },
	            beforeSend: function(jqXHR, settings) {
	                jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
	            },
	            success: function(data) {
	            },
	            error: function(XMLHttpRequest, textStatus, errorThrown) {
	            },
				complete: function () {
					$("#seller_step_tips_modal").modal("hide");
				}
			});
		});
		
		$("#signup .seller-step-qa-icon").click(function(){
			$("#seller_step_tips_modal").modal("show");
		});
		
		$("#signup #hide_seller_step_tips").off("click").on("click", function() {
			Raisy.users.show_seller_step_tips = false;
			
			$.ajax('/ajax/sellersteppopup', {
				type: 'GET',
				cache: false,
				data: { popup: "disable" },
	            beforeSend: function(jqXHR, settings) {
	                jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
	            },
	            success: function(data) {
	            },
	            error: function(XMLHttpRequest, textStatus, errorThrown) {
	            },
				complete: function () {
					$("#seller_step_tips_modal").modal("hide");
				}
			});
		});
      function upload_minilogo() {
          function getRoundedCanvas(sourceCanvas) {
              var canvas = document.createElement('canvas');
              var context = canvas.getContext('2d');
              var width = sourceCanvas.width;
              var height =sourceCanvas.height;
              canvas.width = width;
              canvas.height = height;
              context.beginPath();
              context.arc(width / 2, height / 2, Math.min(width, height) / 2, 0, 2 * Math.PI);
              context.strokeStyle = 'rgba(0,0,0,0)';
              context.stroke();
              context.clip();
              //context.scale(0.3,0.3);
              context.drawImage(sourceCanvas, 0, 0, width, height);

              return canvas;
          }

          var $img_cropper = $("#minilogo_cropper");
          var $button = $('#btn-crop-minilogo');
          var $minilogoview = $(".js-minilogo-view");
          var $result = $('#result');

          var croppable = false;
          function initcropper()
          {
              $img_cropper.cropper({
                  aspectRatio: 1,
                  viewMode: 1,
                  built: function () {
                      croppable = true;
                  },
                  crop: function (e) {
                      // Output the result data for cropping image.
                      //console.log(e.x);
                      //console.log(e.y);
                      //console.log(e.width);
                      //console.log(e.height);
                      //console.log(e.rotate);
                      //console.log(e.scaleX);
                      //console.log(e.scaleY);
                      _this.minilogo_data_cropper.x= e.x;
                      _this.minilogo_data_cropper.y= e.y;
                      _this.minilogo_data_cropper.width= e.width;
                      _this.minilogo_data_cropper.height= e.height;
                      _this.minilogo_data_cropper.scaleX= e.scaleX;
                      _this.minilogo_data_cropper.scaleY= e.scaleY;

                      _this.minilogo_data_cropper.filename=$img_cropper.attr("src");
                  }
              });
          }

          $button.on('click', function () {
              var croppedCanvas;
              var roundedCanvas;

              if (!croppable) {
                  return;
              }
              // Crop
              croppedCanvas = $img_cropper.cropper('getCroppedCanvas');
              //croppedCanvas.width=150;
              //croppedCanvas.height=150;
              // Round
              roundedCanvas = getRoundedCanvas(croppedCanvas);

              // Show
              $minilogoview.attr("src", roundedCanvas.toDataURL());
              $("#minilogo_upload_view").find("input").val(_this.minilogo_data_cropper.filename);
              _this.minilogo_data_cropper.ischage=true;
              //$result.html('<img src="' + roundedCanvas.toDataURL() + '">');
          });

          $('#minilogo_upload').fileupload({
              forceIframeTransport: true,	// To work with IE under 10, use iframe always and do some tricks
              autoUpload: true,
              add: function (e, data) {
                  //$('.add-campaign-photo .fa-spin').show();
                  //$("#minilogo_upload_view").parent().find(".loader").show();
                  $(".minilogo_cropper_box").show();
                  $(".minilogo-progress").hide().find(".progress-bar").css("width", "0").find('span').text("0%");
                  $(".minilogo-progress").show();
                  data.submit();
              },
              done: function (e, data) {
                  //$('.add-campaign-photo .fa-spin').hide();
                  var txt = $(data.result[0].body).text();	// Thanks to IE, work became so ugly
                  // Upload#save action returns filename+'upload.done' to indicate a successful uploading
                  //alert(txt);
                  if (txt.indexOf("upload.done") > 0) {
                      var txt = txt.replace("upload.done", "");
                      var json = JSON.parse(txt);
                      $img_cropper.attr("src", json.fullname);
                      initcropper();
                      $img_cropper.cropper('reset').cropper('replace', json.fullname);
                      $(".minilogo_cropper_box").show();
                      window.setTimeout(function(){
                          $(".minilogo-progress").hide().find(".progress-bar").css("width", 0 + "%").find('span').text(0 + "%");
                      },1000)


                  }
                  else if(txt=="max") {
                      alert("不能上传过大的图片");
                      // txt="Internal Server Error";
                      //$("<div/>").text(txt).appendTo("#more_photo_result");
                  }
                  else
                  {
                      alert("上传图片失败请确定你的图片格式是否正确！或刷新后重试");
                  }
              },
              progress: function (e, data) {//设置上传进度事件的回调函数

                  var progress = Math.round((data.loaded * 100.0) / data.total);
                  $(".minilogo-progress").find(".progress-bar").css("width", progress + "%").find('span').text(progress + "%");

              },
              progressall: function (e, data) {//设置上传进度事件的回调函数

                  var progress = Math.round((data.loaded * 100.0) / data.total);
                  $(".minilogo-progress").find(".progress-bar").css("width", progress + "%").find('span').text(progress + "%");

              },
              fail: function (e, data) {
                  // No longer triggered when using iframe as it always get back the response, even if 404 or 500
                  // which will be considered as errors when using XHR

                  alert("数据上传失败请刷新后重试");
              }
          })
      }
      upload_minilogo();
      $(".js-btn-submit").bind("click",function(){
          $(this).prop('disabled', true).find('span.text').text('保存中...').siblings('span.loader').show('fast', function () {

              var data=new Array();

              if(Raisy.users.minilogo_data_cropper!=null&&Raisy.users.minilogo_data_cropper.ischage==true)
              {
                  data[0]=_this.minilogo_data_cropper;

              }
              //alert(data.length);
              if(data.length>0)
              {
                  $.post("/upload/photo_croper", {cropperdata1:data[0]}).complete(formsubmit());
              }
              else
              {
                  formsubmit();
              }

              function formsubmit()
              {
                  Raisy.users.minilogo_data_cropper.ischage==false;
                  window.setTimeout(function () {
                      $("#profile_form").submit();
                  }, 50);
              }

          });
      });
  },
  
  show_seller_step_tips: true,
  
	sendContactEmails: function(btn) {
		var ed=tinymce.get("txtEmailBody");
		var content=$.trim(ed.getContent());
		var sellerid = $("#hidsellerid").val() || "";
		var campaignid = $("#hidcampaignid").val() || "";
		var contact_ids="";
		
		$(".contact-id:checked").each(function(){
			contact_ids+=this.value + ",";
		});
		
		if (contact_ids=="") return;
		
		contact_ids=contact_ids.substring(0, contact_ids.length-1);
		
		var $button=$(btn);
		
        $button.prop('disabled', true).find('span.text').text('Sending Email...').siblings('span.loader').show(200, function() {
			$.ajax('/ajax/emailcontacts', {
				type: 'POST',
				data: { is_send_email: true, seller_id: sellerid, campaign_id: campaignid, email_text: content, contact_ids: contact_ids },
	            beforeSend: function(jqXHR, settings) {
	                jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
	            },
	            success: function(data) {
	            },
	            error: function(XMLHttpRequest, textStatus, errorThrown) {
	            },
				complete: function () {
					$button.prop('disabled', false).find('span.text').text('Send Email').siblings('span.loader').hide();
					
					// Hide modal if any
					$('#contacts_modal').data("email-sent", "yes").modal('hide');
				}
			});
        });
	},
	previewContactEmail: function(btn) {
		var ed=tinymce.get("txtEmailBody");
		var $container=$(ed.getContainer());

		if (!$container.hasClass("mce-tinymce")) {
			$container=$container.parents(".mce-tinymce").first();
		}
	
		var content=$.trim(ed.getContent({format: "text"}));
		var maxLength=parseInt(ed.getParam("maxlength"));
		var count=maxLength-content.length;
	
		if (count<0) {
			$container.find(".tinymce-charcount span").css("color", "#b94a48").text("Up to "+maxLength+" characters");
			
			window.Raisy.alert("Custom Email Text can only have a maximum of " + maxLength + " characters");
			
			return;
		}
		
		$container.find(".tinymce-charcount span").css("color", "#00aaff").text(count);
		
		content=$.trim(ed.getContent());
		
		var $button = $(btn);
		var sellerid = $("#hidsellerid").val() || "";
		var campaignid = $("#hidcampaignid").val() || "";
		
        $button.prop('disabled', true).find('span.text').siblings('span.loader').show(200, function() {
            $.ajax('/ajax/previewcontactemail', {
                type: 'POST',
				data: { seller_id: sellerid, campaign_id: campaignid, email_text: content },
                beforeSend: function(jqXHR, settings) {
                    jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                },
                success: function(data) {
					content=data;
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                },
				complete: function () {
					// Just in case any error occurred
					content = content.replace(/\{\{fundraiser\.signup\.url\}\}/g, "")
					content = content.replace(/\{\{fundraiser\.chairperson\}\}/g, "");
					content = content.replace(/\{\{fundraiser\.url\}\}/g, "");
		            content = content.replace(/\{\{fundraiser\.title\}\}/g, "");
		            content = content.replace(/\{\{fundraiser\.tagline\}\}/g, "");
		            content = content.replace(/\{\{fundraiser\.goal\}\}/g, "");
		            content = content.replace(/\{\{organization\.name\}\}/g, "");
		            content = content.replace(/\{\{collection\.name\}\}/g, "");
		            content = content.replace(/\{\{seller\.fullname\}\}/g, "");
		            content = content.replace(/\{\{seller\.url\}\}/g, "");
					content = content.replace(/\{\{contact\.greeting\}\}/g, "");
					
					$button.prop('disabled', false).find('span.text').siblings('span.loader').hide();
					
					$("#preview_contact_email_modal .modal-body").html(content);
					$("#preview_contact_email_modal").modal("show");
				}
            });
        });
	},
	
  contactRowHtml: '<tr class="contact-row contact-new-row" style="display:none;">' +
		'<td style="width:160px;">' + 
			'<input type="hidden" class="contact-id" value="" />' + 
			'<input type="hidden" class="contact-media-id" value="5" />' + 
			'<span class="contact-item-text contact-firstname-text"></span>' +
			'<input type="text" class="form-control contact-update-input contact-firstname-input" value="" maxlength="50" placeholder="比如： 张" />' +
		'</td>' +
		'<td style="width:160px;">' +
			'<span class="contact-item-text contact-lastname-text"></span>' +
			'<input type="text" class="form-control contact-update-input contact-lastname-input" value="" maxlength="50" placeholder="比如： 鹏" />' +
		'</td>' +
		'<td style="width:160px;">' +
			'<span class="contact-item-text contact-greetings-text"></span>' +
			'<input type="text" class="form-control contact-update-input contact-greetings-input" value="" maxlength="50" placeholder="比如： 外婆" />' +
		'</td>' +
		'<td>' +
			'<span class="contact-item-text contact-email-text"></span>' +
			'<input type="text" class="form-control contact-update-input contact-email-input" value="" maxlength="100" style="max-width:100%;" />' +
		'</td>' +
		'<td class="contact-edit-cell contact-ops1-cell">' +
			'<span class="glyphicon glyphicon-pencil contact-edit-btn show_tooltip" data-title="Edit"></span></td>' +
		'<td class="contact-delete-cell contact-ops1-cell">' + 
			'<span class="glyphicon glyphicon-trash contact-del-btn show_tooltip" data-title="Delete"></span></td>' +
		'<td class="contact-update-cell contact-ops2-cell">' +
			'<span class="glyphicon glyphicon-ok contact-save-btn show_tooltip" data-title="Save"></span></td>' +
		'<td class="contact-cancel-cell contact-ops2-cell">' +
			'<span class="glyphicon glyphicon-remove contact-cancel-btn show_tooltip" data-title="Cancel"></span></td>' +
		'<td class="contact-loader-cell">' + 
			'<span class="loader loader-black contact-update-loader" style="visibility:hidden;"></span></td>' +
		'</tr>',
  
  addNewContactClick: function() {
	if ($(".contact-new-row").length>0) return;
		
	$(".contact-table-body").prepend(Raisy.users.contactRowHtml);

	var row=$(".contact-new-row");

	row.find(".contact-edit-btn").click(function(){
		Raisy.users.editContactClick(this);
	}).find(".show_tooltip").tooltip();

	row.find(".contact-save-btn").click(function(){
		Raisy.users.updateContactClick(this);
	}).find(".show_tooltip").tooltip();

	row.find(".contact-cancel-btn").click(function(){
		Raisy.users.cancelContactClick(this);
	}).find(".show_tooltip").tooltip();

	row.find(".contact-del-btn").click(function(){
		Raisy.users.deleteContactClick(this);
	}).find(".show_tooltip").tooltip();

	row.find(".contact-item-text").hide();
	row.find(".contact-ops1-cell").hide();
	row.find(".contact-ops2-cell").show();
	row.find(".contact-update-input").show();
	
	// Show cancel button after saved
	row.find(".contact-cancel-btn").hide();
	
	if ($(".contact-row").length>1) {
		row.fadeIn(200);
	}
	else {
		row.show();
	
		$(".contact-table").fadeIn(200, function(){
			//row.find(".contact-update-input").first().focus();
		});
	}
  },
  
  addImportedContactRow: function(contacts){
	$(contacts).each(function(){
		var contact_id=this.id;
		var has_contact=false;
		
		$(".contact-id").each(function(){
			if (this.value==contact_id) has_contact=true;
		});
		
		if (!has_contact) {
			var html=Raisy.users.contactRowHtml
		
			html=html.replace("contact-new-row", "contact-imported-row");
		
			$(".contact-table-body").append(html);

			var row=$(".contact-imported-row").first();

			row.find(".contact-edit-btn").click(function(){
				Raisy.users.editContactClick(this);
			}).find(".show_tooltip").tooltip();

			row.find(".contact-save-btn").click(function(){
				Raisy.users.updateContactClick(this);
			}).find(".show_tooltip").tooltip();

			row.find(".contact-cancel-btn").click(function(){
				Raisy.users.cancelContactClick(this);
			}).find(".show_tooltip").tooltip();

			row.find(".contact-del-btn").click(function(){
				Raisy.users.deleteContactClick(this);
			}).find(".show_tooltip").tooltip();
		
			row.find(".contact-id").first().val(contact_id);
			row.find(".contact-media-id").first().val(this.media_id);
			row.find(".contact-firstname-text").first().text(this.first_name);
			row.find(".contact-lastname-text").first().text(this.last_name);
			row.find(".contact-email-text").first().text(this.email_address);
			row.find(".contact-greetings-text").first().text("");
		
			row.removeClass("contact-imported-row");
			row.show();
		}
	});
	
	if ($(".contact-row").length>0) {
		$(".contact-table").show();
	}
	
	// Add new contact row after imported
	Raisy.users.addNewContactClick();
  },
  
  cancelContactClick: function(cell) {
	var row=$(cell).closest(".contact-row");
	
	if (row.hasClass("contact-new-row")) {
		row.fadeOut(200, function(){ 
			row.remove();
		});
	}
	else {
		row.find(".contact-update-input").hide();
		row.find(".contact-ops2-cell").hide();
		row.find(".contact-ops1-cell").show();
		row.find(".contact-item-text").show();
	}
  },
  
  deleteContactClick: function(cell) {
	window.Raisy.confirm("Are you sure that you want to delete this contact?", function(result){
		if (!result) return;
		
	  	var row=$(cell).closest(".contact-row");
		var contact_id=row.find(".contact-id").first().val();
	
		if (contact_id!="") {
			row.find(".contact-update-loader").first().css("visibility", "visible");
		
			$.ajax('/ajax/deletecontact', {
			  	type: 'POST',
				data: { contact_id: contact_id },
				beforeSend: function(jqXHR, settings) {
				  jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
				},
				success: function(data) {
					if (data=="") {
						row.find(".contact-update-loader").first().css("visibility", "hidden");
					
						window.Raisy.alert("抱歉，删除联系人时出了问题，请稍后再试。");
					}
					else {
						row.fadeOut(200, function(){
							row.remove();
						});
					}
				},
				error: function(XMLHttpRequest, textStatus, errorThrown) {
					row.find(".contact-update-loader").first().css("visibility", "hidden");
				
					window.Raisy.alert("抱歉，删除联系人时出了问题，请稍后再试。");
				},
				complete: function () {
				
				}
			});
		}
	});
  },
  
  editContactClick: function(cell) {
	var row=$(cell).closest(".contact-row");
	
	row.find(".contact-firstname-input").first().val(
		row.find(".contact-firstname-text").first().text()).closest("td").removeClass("has-error");
		
	row.find(".contact-lastname-input").first().val(
		row.find(".contact-lastname-text").first().text()).closest("td").removeClass("has-error");
		
	row.find(".contact-email-input").first().val(
		row.find(".contact-email-text").first().text()).closest("td").removeClass("has-error");
		
	row.find(".contact-greetings-input").first().val(
		row.find(".contact-greetings-text").first().text()).closest("td").removeClass("has-error");
		
	row.find(".contact-item-text").hide();
	row.find(".contact-ops1-cell").hide();
	row.find(".contact-ops2-cell").show();
	row.find(".contact-update-input").show();
  },
  
  updateContactClick: function(cell) {
	var row=$(cell).closest(".contact-row");
	var contact_id=row.find(".contact-id").first().val();
	var media_id=row.find(".contact-media-id").first().val();
	var first_name=row.find(".contact-firstname-input").first().val();
	var last_name=row.find(".contact-lastname-input").first().val();
	var email=row.find(".contact-email-input").first().val();
	var greetings=row.find(".contact-greetings-input").first().val();
	
	if (!window.Raisy.valid_email(email)) {
		row.find(".contact-email-input").first().closest("td").addClass("has-error");
		return;
	}
	
	row.find(".contact-email-input").first().closest("td").removeClass("has-error");
	row.find(".contact-update-loader").first().css("visibility", "visible");
	
	$.ajax('/ajax/updatecontact', {
	  	type: 'POST',
		data: { contact_id: contact_id,
			first_name: first_name,
			last_name: last_name,
			email: email,
			greetings: greetings,
			media_id: media_id
		},
		beforeSend: function(jqXHR, settings) {
		  jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
		},
		success: function(data) {
			if (data!="") {
				if (data=="existed") {
					window.Raisy.alert("The email you entered has already existed among your contacts");
				}
				else {
					row.removeClass("contact-new-row");
				
					row.find(".contact-id").first().val(data);
					row.find(".contact-firstname-text").first().text(first_name);
					row.find(".contact-lastname-text").first().text(last_name);
					row.find(".contact-email-text").first().text(email);
					row.find(".contact-greetings-text").first().text(greetings);
				
					row.find(".contact-update-input").hide();
					row.find(".contact-ops2-cell").hide();
					row.find(".contact-ops1-cell").show();
					row.find(".contact-item-text").show();
					
					// Show cancel button and add a new contact row
					row.find(".contact-cancel-btn").show();
					
					Raisy.users.addNewContactClick();
				}
			}
			else {
				window.Raisy.alert("抱歉，保存联系人时出了问题，请稍后再试。");
			}
		},
		error: function(XMLHttpRequest, textStatus, errorThrown) {
			window.Raisy.alert("抱歉，保存联系人时出了问题，请稍后再试。");
		},
		complete: function () {
			row.find(".contact-update-loader").first().css("visibility", "hidden");
		}
	});
  },
	
	sellerTypeSelectorClick: function(btn, acc_type) {
		if (acc_type==4) {
			window.location.href = "/users/sign_in";
		}
		else
		{
			$("#user_account_type").val(acc_type);
			$("#signup .btn-seller-selector").css("border-color", "rgb(173, 173, 173)");
			$(btn).css("border-color", "rgb(66, 139, 202)");
		}
	},
	
	showSignupSelector:function(){
		$("#seller_signup_form13").hide();
		$("#seller_signup_form14").hide();
		$("#seller_signup_form18").hide();
		$("#seller_signup_selector").show();
	},
	
	showSignupForm13:function(){
		$("#user_account_type").val("3");
		$("#seller_signup_selector").hide();
		$("#seller_signup_form13").show();
		$("#seller_signup_form14").hide();
		$("#seller_signup_form18").hide();
	},
	
	showSignupForm14:function(){
		$("#user_account_type").val("2");
		$("#seller_signup_selector").hide();
		$("#seller_signup_form13").hide();
		$("#seller_signup_form14").show();
		$("#seller_signup_form18").hide();
	},
	
	showSignupForm18:function(){
		$("#user_account_type").val("1");
		$("#seller_signup_selector").hide();
		$("#seller_signup_form13").hide();
		$("#seller_signup_form14").hide();
		$("#seller_signup_form18").show();
	},
	
	showExistingSeller:function(str){
		if(str=="1"){
			$("#seller_signup_parent1").show();
			$("#seller_signup_parent2").hide();
		}
		else{
		    $("#seller_signup_parent1").hide();
		    $("#seller_signup_parent2").show();
	    }
	},
	
	showOrderDetailReport:function(){
		$("#orderdetailreportsection").show();
		$("#dashboardsection").hide();
	},
	
	submitSellerSignUpForm:function(form){
		var acc_type=$("#user_account_type").val();
		var email="";
		var msg="";
		var $seller_error;
		var $seller_message;
		
		if (acc_type=="3") 
		{
			email=$("#seller13_email").val();
			msg="抱歉，这个邮箱已经被注册。";
			$seller_error=$("#seller13_error");
			$seller_message=$("#seller13_message");
		}
		if (acc_type=="2") 
		{
			email=$("#seller14_email").val();
			msg="抱歉，这个销售的邮箱已经被注册。";
			$seller_error=$("#seller14_error");
			$seller_message=$("#seller14_message");
		}
		if (acc_type=="1") 
		{
			email=$("#seller18_email").val();
			msg="抱歉，这个邮箱已经被注册。";
			$seller_error=$("#seller18_error");
			$seller_message=$("#seller18_message");
		}
		
		$("#seller-social-error").hide();
				
		if ($("#seller-social-error").length==1) {
			email=$("#user_email").val();
			msg="抱歉，这个帐户已被注册。";
			$seller_error=$("#seller-social-error");
			$seller_message=$("#seller-social-message");
		}
		
		var can_continue=true;
		 
		$.ajax({
			method: "get",
			url: "/user/lookup?email=" + encodeURIComponent(email),
			dataType: "json",
			cache: false,
			async: false,
			success: function(d){
				if (d && d.user) {
					can_continue = false;
				
					$seller_error.show();
					$seller_message.text(msg);
				}
			}
		}); 
		
		if (!can_continue) return false;
		
		form.submit();
	}
}
