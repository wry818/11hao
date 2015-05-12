Raisy.shop = {
    init: function() {

        var _this = this;
		
		$('#campaign-show #slides').slides({
			width: 280,
			height: 280,
			pagination: true,
			generateNextPrev: true,
			next: "slides-next",
			prev: "slides-prev",
			play: 5000,
			effect: 'slide',
			fadeSpeed: 500,
			slideSpeed: 500,
			currentClass: "slides-current"
		}).show();

        $('.product-form .form-control').on('change', function() {
            $(this).parents('.form-group').removeClass('has-error');
        });

        $('.add-to-cart').on('click', function(e) {
            e.preventDefault();
            var errors = false;
            var $this = $(this);

            var $form = $this.parents('form.product-form');

            $form.find('.required').each(function(index, element) {
                $element = $(element)
                if($element.val().length == 0) {
                    $element.parents('.form-group').addClass('has-error');
                    errors = true;
                }
            });

            if(!errors) {
                $this.prop('disabled', true).find('span.text').text('加入订单').siblings('span.loader').show();
                $.ajax('/ajax/update-cart', {
                    type: 'POST',
                    data: $form.serialize(),
                    beforeSend: function(jqXHR, settings) {
                        jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                    },
                    success: function(data) {
                        if(data != 'fail') {
                          $this.parents('.modal').modal('hide');
                          $('#checkout-modal').html(data);
                          _this.attachCartEvents();
													
													if (data.indexOf("-!-js-!-")<0) {
														$('#checkout-modal').modal('show');
													}
                        }
												
                        $this.prop('disabled', false).find('span.text').text('加入订单').siblings('span.loader').hide();
                    }
                });
            }
        });

        _this.attachCartEvents();

        $('input.delivery-method').on("change", function() {
            var $this = $(this);
            var order_id = $('#order_id').val();
            var $sidebar = $('.sidebar');
            $sidebar.css('opacity', '0.5').find('.order-summary span.loader').show();

            $('.delivery-panel').hide();
            if($this.val() == '2') {
                $('.shipping').fadeIn();
                $('.shipping-inputs').fadeIn();
             } else {
                $('.pickup').fadeIn();
                $('.shipping-inputs').hide();
            }

            $.ajax('/ajax/update-delivery', {
                type: 'POST',
                dataType: "json",
                data: { order_id: order_id, delivery_method: $this.val() },
                beforeSend: function(jqXHR, settings) {
                    jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                },
                success: function(data) {
                    if(!data.error) {
                        $('#shipping_fee').html('￥' + data.shipping_fee);
                        $('#processing_fee').html('￥' + data.processing_fee);
                        $('#grand_total').html('￥' + data.grand_total);
                        $('#button_total').html('￥' + data.grand_total);
                        if(data.show_shipping) {
                            $('.summary-shipping').show();
                        } else {
                            $('.summary-shipping').hide();
                        }
                        if(data.show_processing) {
                            $('.summary-processing').show();
                        } else {
                            $('.summary-processing').hide();
                        }
                    }
                    $sidebar.css('opacity', '1').find('.order-summary span.loader').hide();
                }
            });
        });
		
		$(".product-dropdown-option").change(function(){
			var span=$("#product_price_span");
			
			if (this.value=="") {
				var price=span.data("price");
				var origin_price=span.data("origin-price");
				
				span.text(price);
				
				// if (price==origin_price) {
				// 	$("#product_origin_price_span").text("");
				// 	$("#product_price_dash_span").hide();
				// }
				// else {
				// 	$("#product_origin_price_span").text("￥" + origin_price);
				// 	$("#product_price_dash_span").show();
				// }
			}
			else {
				var price=$(".product-dropdown-option option:selected").data("price");
				var origin_price=$(".product-dropdown-option option:selected").data("origin-price");
				
				span.text(price);
				
				// if (price==origin_price) {
				// 	$("#product_origin_price_span").text("");
				// 	$("#product_price_dash_span").hide();
				// }
				// else {
				// 	$("#product_origin_price_span").text("￥" + origin_price);
				// 	$("#product_price_dash_span").show();
				// }
			}
		});

    }, //end of shop.init

    attachCartEvents: function() {
        var _this = this;

        //Removing an item from the cart
        $('#checkout-modal .delete-item').on("click", function(e) {
            e.preventDefault();
            var $this = $(this);
            var $well = $this.parents('.well');
            var item_id = $well.find('.item-id').val();
            var order_id = $('#order_id').val();
			var parent_page = "";
			
			if ($("#checkout_modal_parentpage").length>0)
				parent_page = $("#checkout_modal_parentpage").val();

            $('#cart_modal_checkout').attr('disabled', true).find('span.text').siblings('span.loader').show();
            $.ajax('/ajax/update-cart', {
                type: 'POST',
                data: { item: { item_id: item_id, order_id: order_id, quantity: 0 }, parent_page: parent_page },
                beforeSend: function(jqXHR, settings) {
                    jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                },
                success: function(data) {
									if(data != 'fail') {
										$('#checkout-modal').html(data);
										_this.attachCartEvents();

										$osc = $("#order_summary_container");

										if ($osc.length>0) {
											$.ajax('/ajax/order-summary', {
												type: 'POST',
												data: { order_id: order_id },
												beforeSend: function(jqXHR, settings) {
													jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
												},
												success: function(data) {
													if(data != 'fail') {
														$osc.html(data);
														$("#button_total").text($("#grand_total").text());
														
														$('.show_tooltip_html').tooltip({
														    html: true
														});
														
														if ($(".item-dm-1").length>0) 
															$(".dm-instruction-1").show();
														else 
															$(".dm-instruction-1").hide();
															
														if ($(".item-dm-2").length>0) 
															$(".dm-instruction-2").show();
														else 
															$(".dm-instruction-2").hide();

														if ($(".item-dm-3").length>0) 
															$(".dm-instruction-3").show();
														else 
															$(".dm-instruction-3").hide();
													}
												}
											});
										}
									}
                }
            });
        });

        //Changing the quantity of an item in the cart
        $('#checkout-modal .quantity-input').on("change", function(e) {
            e.preventDefault();
            var $this = $(this);
            var $well = $this.parents('.well');
            var item_id = $well.find('.item-id').val();
            var quantity = $this.val();
            var order_id = $('#order_id').val();
			var parent_page = "";
			
			if ($("#checkout_modal_parentpage").length>0)
				parent_page = $("#checkout_modal_parentpage").val();

            $('#cart_modal_checkout').attr('disabled', true).find('span.text').siblings('span.loader').show();
            $.ajax('/ajax/update-cart', {
                type: 'POST',
                data: { item: {item_id: item_id, order_id: order_id, quantity: quantity }, parent_page: parent_page },
                beforeSend: function(jqXHR, settings) {
                    jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                },
                success: function(data) {
                  if(data != 'fail') {
                    $('#checkout-modal').html(data);
                    _this.attachCartEvents();
				
										$osc = $("#order_summary_container");
				
										if ($osc.length>0)
										{
					            $.ajax('/ajax/order-summary', {
					                type: 'POST',
					                data: { order_id: order_id },
					                beforeSend: function(jqXHR, settings) {
														jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
					                },
					                success: function(data) {
														if(data != 'fail') {
															$osc.html(data);
															$("#button_total").text($("#grand_total").text());
															
															$('.show_tooltip_html').tooltip({
															    html: true
															});
															
															if ($(".item-dm-1").length>0) 
																$(".dm-instruction-1").show();
															else 
																$(".dm-instruction-1").hide();
																
															if ($(".item-dm-2").length>0) 
																$(".dm-instruction-2").show();
															else 
																$(".dm-instruction-2").hide();

															if ($(".item-dm-3").length>0) 
																$(".dm-instruction-3").show();
															else 
																$(".dm-instruction-3").hide();
														}
													}
					            });
										}
              		}
                }
            });
        });

        //Update the cart count on the show page
        var num_items = $('#checkout-modal .items').attr('data-total');
        if(num_items == 1) {
            $('#cart-count').html(num_items + ' 件商品');
        } else {
            $('#cart-count').html(num_items + ' 件商品');
        }
        if(num_items > 0) {
            $('.view-cart').html('View/Checkout');
        } else {
            $('.view-cart').html('View');
        }
    }, // end of attachCartEvents

    submitPaymentForm: function(form) {
		$("#stripe_error").hide();
		$("#stripe_message").text("");
        $('#errors').hide();
        $('#errors').html('');
        $('#payment-form-submit').prop('disabled', true).find('span.text').text('处理中，请稍候...').siblings('span.loader').show();

		Stripe.card.createToken({
		  number: $("#card_number").val(),
		  cvc: $("#cvv").val(),
		  exp_month: $("#expiration_month").val(),
		  exp_year: $("#expiration_year").val(),
		  name: $("#fullname").val()
		}, function (status, response) {
			$("<div/>").text(JSON.stringify(response)).appendTo($("#stripe"));
		
			if (response.error) {
				$('#payment-form-submit').prop('disabled', false).find('span.text')
					.text('Place your order').siblings('span.loader').hide();
					
				$("#stripe_message").text(response.error.message);
				$("#stripe_error").show();
			} else {
				$("#stripe_token").val(response.id);
				
				// Clear sensitive data then submit
				$(".stripe-data").val("");
				
				form.submit();
			}
		});
    } // end of submitPaymentForm
}
