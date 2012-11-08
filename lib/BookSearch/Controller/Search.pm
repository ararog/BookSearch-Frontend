package BookSearch::Controller::Search;
use Moose;
use namespace::autoclean;
use ElasticSearch;
use ElasticSearch::SearchBuilder;
use Data::Dumper;
use POSIX;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

BookSearch::Controller::Search - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;

  $c->response->body('Matched BookSearch::Controller::Search in Search.');
}


=head2 execute

=cut

sub execute :Path :Args(0) {
  my ( $self, $c ) = @_;

  my $query = $c->request->query_parameters->{q};
  my $page  = $c->request->query_parameters->{page};
  
  my %facet = ();
  $facet{"name"}  = $c->request->query_parameters->{"facet.name"};
  $facet{"value"} = $c->request->query_parameters->{"facet.value"};

  my $es = ElasticSearch->new(
    servers => 'localhost:9200',
	trace_calls  => '/tmp/search.log'
  );
  
  if($page eq "") {
	$page = 1;
  }

  
  my %filters = ();
  if($facet{"name"} ne "") {
	$filters{$facet{"name"}} = $facet{"value"};
  }

  my $results = $es->search(
	index  => "booksearch",    
	type   => "doc",
	queryb => {
	  content => $query,
	  -filter => \%filters
	},
	from   => ($page - 1) * 10,
	size   => 10,
	fields => ['url', 'title', 'author', 'date', 'type'],
	highlight => {
	  fields => {
		content => {
		  fragment_size => 150, 
		  number_of_fragments => 2
		}
	  }
	},
	facets => {
	  author => { 
		terms => {
		  field => "author",
		  size => 10
		} 
	  }
	}
  );  

  my @results;
  for my $result ( @{$results->{'hits'}{'hits'}} ) {
	  my $r = $result->{'fields'};

	  my $title = $r->{'title'};
	  if ($title eq "") {
		$title = "No title";
	  }

	  my $author = $r->{'author'};
	  if ($author eq "") {
		$author = "No author";
	  }

	  push @results, {
		  url     => $r->{'url'},
		  title   => $title,
		  author  => $author,
		  date    => $r->{'date'},
		  content => $result->{'highlight'}{'content'},
	  };
  }

  my $hitCount = $results->{'hits'}{'total'};

  my $numberOfPages = ceil($hitCount / 10);

  $c->stash->{template} = 'search/search_results.tt';
  $c->stash->{results} = \@results;
  $c->stash->{facets} = $results->{'facets'};
  $c->stash->{page} = $page;
  $c->stash->{hitCount} = $hitCount;
  $c->stash->{numberOfPages} = $numberOfPages;
  $c->forward( $c->view('HTML') );
}

=head1 AUTHOR

Rogério Araújo

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
