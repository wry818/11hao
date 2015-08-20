//These are javascript methods that are used by both the main app and the admin app
$(document).ready(function() {

    $('.show-popover').popover();
    $('.show_tooltip').tooltip();
	
	$('.show_tooltip_html').tooltip({
	    html: true
	});		
	
    $(".aaaaa").fileupload({
        add: function(e, data) {
            // var acceptFileTypes = /^image\/(gif|jpe?g|png)$/i;
//             if(data.originalFiles[0]['type'].length && !acceptFileTypes.test(data.originalFiles[0]['type'])) {
//                 alert('Not an accepted file type');
//             } else {
//                 data.submit();
//             }

			data.submit();
        },
        dropZone: "#drop-zone",
        dragover: function (e) {
            e.preventDefault();
            $('#drop-zone').css("border-color", "green");
        },
        start: function (e) {
			$(".status").text("");
			$(".progress").not(".camp-photo-progress").hide().find(".progress-bar").css("width", "0").find('span').text("0%");
            $(".progress").not(".camp-photo-progress").show();
        },
        progress: function (e, data) {
            var prog = Math.round((data.loaded * 100.0) / data.total);
            $(".status").text("上传中，请稍候...");
            $(".progress-bar").css("width", prog + "%").find('span').text(prog + "%");
        },
        fail: function (e, data) {
            $(".status").text("抱歉! 上传失败，请稍后再试");
            $(".progress").not(".camp-photo-progress").hide().find(".progress-bar").css("width", "0").find('span').text("");
            $("#drop-zone").css("border-color", "#ccc");
        }
    });
	
    // $(".cloudinary-fileupload").fileupload({
//         add: function(e, data) {
// 			alert(1);
//             // var acceptFileTypes = /^image\/(gif|jpe?g|png)$/i;
// //             if(data.originalFiles[0]['type'].length && !acceptFileTypes.test(data.originalFiles[0]['type'])) {
// //                 alert('Not an accepted file type');
// //             } else {
// //                 data.submit();
// //             }
//
// 			data.submit();
//         },
//         dropZone: "#drop-zone",
//         dragover: function (e) {
//             e.preventDefault();
//             $('#drop-zone').css("border-color", "green");
//         },
//         start: function (e) {
// 			alert(2);
// 			$(".status").text("");
// 			$(".progress").not(".camp-photo-progress").hide().find(".progress-bar").css("width", "0").find('span').text("0%");
//             $(".progress").not(".camp-photo-progress").show();
//         },
//         progress: function (e, data) {
//             var prog = Math.round((data.loaded * 100.0) / data.total);
//             $(".status").text("上传中，请稍候...");
//             $(".progress-bar").css("width", prog + "%").find('span').text(prog + "%");
//         },
//         fail: function (e, data) {
//             $(".status").text("抱歉! 上传失败，请稍后再试");
//             $(".progress").not(".camp-photo-progress").hide().find(".progress-bar").css("width", "0").find('span').text("");
//             $("#drop-zone").css("border-color", "#ccc");
//         }
//     }).off("cloudinarydone").on("cloudinarydone", function (e, data) {
//         $(".status").text("");
//         alert(4);
// 		$(".progress").not(".camp-photo-progress").hide().find(".progress-bar").css("width", "0").find('span').text("");
//         $("#drop-zone").css("border-color", "#ccc");
//         var params = {
//             format: data.result.format,
//             width: 100,
//             height: 100,
//             crop: "limit",
// 						angle: "exif"
//         };
//         var html = $.cloudinary.image(data.result.public_id, params);
// 		alert(5);
//         $(".preview img").fadeOut(200, function() {
//             $('.preview').html(html);
//
// 			window.setTimeout(function(){
// 				$('.remove-preview').show();
// 				$('.remove-preview').find("#remove_item_image").val("no");
// 			},400)
//         }).fadeIn(200);
//     });
	
	$('.remove-preview button').click(function(){
		$('.remove-preview').find("#remove_item_image").val("yes");
		$('.preview img').attr("src", $('.remove-preview').data("default-url"));
		$('.remove-preview').hide();
	});

    $("#drop-zone").on('dragleave', function() {
        $(this).css("border-color", "#ccc");
    });

    $(".cloudinary-fileupload").on("mouseenter", function() {
        $('.upload-button').addClass("upload-button-hover");
    }).on("mouseleave", function() {
        $('.upload-button').removeClass("upload-button-hover");
    });

    $(".fb-share").on('click', function(e) {
        e.preventDefault();
        $this = $(this);
		
        FB.ui({
            method: 'feed',
            link: $this.attr('data-link'),
        }, function(response){
			if (response && response.post_id) {
				if ($("#hidsellerid").length==1) {
					// Save social share history of the seller
					
		            $.ajax('/ajax/socialshare', {
		                type: 'POST',
						data: { post_id: response.post_id, media_id: 1, seller_id: $("#hidsellerid").val() },
		                beforeSend: function(jqXHR, settings) {
		                    jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
		                },
		                success: function(data) {
		                },
		                error: function(XMLHttpRequest, textStatus, errorThrown) {
		                },
						complete: function () {
						}
		            });
				}
			}
        });
    });
	
	if (window.twttr) {
		window.twttr.ready(function (tw) {
			tw.events.bind('tweet', function(e){
			  if ($("#hidsellerid").length==1) {
				// Save social share history of the seller
		
	            $.ajax('/ajax/socialshare', {
	                type: 'POST',
					data: { post_id: "", media_id: 2, seller_id: $("#hidsellerid").val() },
	                beforeSend: function(jqXHR, settings) {
	                    jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
	                },
	                success: function(data) {
	                },
	                error: function(XMLHttpRequest, textStatus, errorThrown) {
	                },
					complete: function () {
					}
	            });
			}
		  });
		});
	}
});
