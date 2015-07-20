

function skepsis(){
   $('.more').hide();
   $('.linkPlus').click(function() {
                $( this ).next().toggle( "fast" );
          });
  
  
  $('*[data-load]').each(function(){
       //+'?pattern='+$(this).prop('tagName').toLowerCase()//;
       $(this).load($(this).data('load'), complete = function(){
           console.log($(this));
           $(this).find('.more').hide();
          $(this).find('.linkPlus').click(function() {
                $( this ).next().toggle( "fast" );
          });
       } );     
      }); 





};