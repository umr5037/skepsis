

function skepsis(){
  

  
  var path = location.pathname;
  var begin = path.split('/');
  $('a[href="/'+begin[1]+'/'+begin[2]+'"]').parent().addClass('active');

  
  
   $('.more').hide();
   $('.linkPlus').click(function() {
                $( this ).next().toggle( "fast" );
                $( this ).text($( this ).text() == "Masquer" ? "Afficher" : "Masquer");
          });
  
  
  $('*[data-load]').each(function(){
       //+'?pattern='+$(this).prop('tagName').toLowerCase()//;
       $(this).load($(this).data('load'), complete = function(){
           console.log($(this));
           $(this).find('.more').hide();
          $(this).find('.linkPlus').click(function() {
                $( this ).next().toggle( "fast" );
                $( this ).text($( this ).text() == "Masquer" ? "Afficher" : "Masquer");
          });
       } );     
      }); 
};
