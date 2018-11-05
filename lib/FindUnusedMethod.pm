package FindUnusedMethod;
use strict;
use warnings;
use parent qw(PPI::Transform);
use List::Util qw(first);
use List::MoreUtils qw(any);

sub new {
    my ($class) = @_;

    bless {
        # [ [ package, method, line ] ]
        found_methods => [],
        # method => { method => count }
        called_method_names => {},
    }, $class;
}

sub register_file {
    my ($self, $file) = @_;

    my $doc = PPI::Document->new($file);

    # sub ___
    my $method_definitions = $doc->find('PPI::Statement::Sub');
    if ($method_definitions) {

        for my $statement (@$method_definitions) {
            my $method = first { ref($_) eq 'PPI::Token::Word' && $_ ne 'sub' } $statement->children;
            $method->line_number;
            $self->_method_found($file, $method->content, $method->line_number);
        }
    }

    # ->___
    my $operators = $doc->find('PPI::Token::Operator');
    if ($operators) {
        my $arrows = [ grep {
            $_ eq '->'
                && $_->next_sibling
                && ref($_->next_sibling) eq 'PPI::Token::Word';
        } @$operators ];

        for (@$arrows) {
            my $method = $_->next_sibling;
            $self->_method_called($method->content);
        }
    }

    # ___ or ::___
    my $words = $doc->find('PPI::Token::Word');
    if ($words) {
        for (@$words) {
            if ($_ =~ /::/) {
                my $method = (split '::', $_)[-1];
                $self->_method_called($method);
            } else {
                if ((eval { $_->previous_sibling->previous_sibling } || '') ne 'sub') {
                    $self->_method_called($_);
                }
            }
        }
    }

    # &___ , &___() or \&___
    my $symbols = $doc->find('PPI::Token::Symbol') || [];
    for (@$symbols) {
        next unless $_->symbol_type eq '&';
        ( my $sub = $_->content ) =~ s/\A&//;
        $sub = ( split '::', $sub )[-1];
        $self->_method_called($sub);
    }

    return 1;
}

sub _method_found {
    my ($self, $package, $method, $line_number) = @_;
    push @{$self->{found_methods}}, [ $package, $method, $line_number ];
}

sub _method_called {
    my ($self, $method_name) = @_;
    $self->{called_method_names}->{$method_name}++;
}

sub unused_methods {
    my ($self) = @_;

    [ grep {
        my $method = $_->[1];
        ! $self->{called_method_names}->{$method};
    } @{$self->{found_methods}} ];
}

sub this_is_unused_method {
    ...;
}

1;
