

$('.more').hide();
$('.linkPlus').click(function() {

        $( this ).next().toggle( "fast" );

      /*  if ($('.linkPlus').text() === 'Lire la suite') {
            $(this).html('Masquer la suite');
        }
        else {
            $('.linkPlus').html('Lire la suite');
        }*/
});