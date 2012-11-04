package BookSearch::View::HTML;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

BookSearch::View::HTML->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
	INCLUDE_PATH => [
		BookSearch->path_to( 'root', 'templates', 'src' ),
	],
);

=head1 NAME

BookSearch::View::HTML - TT View for BookSearch

=head1 DESCRIPTION

TT View for BookSearch.

=head1 SEE ALSO

L<BookSearch>

=head1 AUTHOR

Rogério Araújo

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
