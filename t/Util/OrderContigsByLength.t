#!/usr/bin/env perl
use strict;
use warnings;
use File::Temp;
use File::Copy;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use Test::File::Contents;
    use_ok('Bio::AssemblyImprovement::Util::OrderContigsByLength');
}

my $data_dir              = 't/data';
my $input_file            = 'contigs_needing_sorted.fa';
my $output_filename       = 'contigs_needing_sorted.sorted.fa';
my $expected_sorted_file  = 'expected_contigs_needing_sorted.fa';

# work in temp directory
my $temp_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $temp_directory = $temp_directory_obj->dirname();
copy(join('/',($data_dir,$input_file)), $temp_directory);

# instantiate
ok my $sort_contigs = Bio::AssemblyImprovement::Util::OrderContigsByLength->new( input_filename  => join('/',($temp_directory,$input_file)) ), 'instantiate object';
is $sort_contigs->output_filename(), join('/',($temp_directory,$output_filename)), 'output filename correct';

# sort config
ok $sort_contigs->run(), 'sort contigs';
files_eq($sort_contigs->output_filename(),join('/',($data_dir,$expected_sorted_file)));
my $user_file_name = join('/',($temp_directory,'user_file_name.fa'));
ok $sort_contigs = Bio::AssemblyImprovement::Util::OrderContigsByLength->new( input_filename  => join('/',($temp_directory,$input_file)), output_filename => $user_file_name ), 'use user outfile';
is $sort_contigs->output_filename(), $user_file_name, 'confirm set user outfile';
ok $sort_contigs->run(), 'sort contigs';
files_eq($user_file_name,join('/',($data_dir,$expected_sorted_file)));

# check renumber function
is $sort_contigs->_rename_contig('NODE_3_length_14_cov_10.00',99), 'NODE_99_length_14_cov_10.00', 'renamed velvet/spades contig';
is $sort_contigs->_rename_contig('NODE_3_length_14_cov_10.00_ID_12345',99), 'NODE_99_length_14_cov_10.00_ID_12345', 'renamed NODE_ plus ID contig';
is $sort_contigs->_rename_contig('NODE_3',99), 'NODE_99', 'renamed NODE_ contig';
is $sort_contigs->_rename_contig('scaffold3|size14',99), 'scaffold99|size14', 'renamed scaffold with size contig';
is $sort_contigs->_rename_contig('scaffold3',99), 'scaffold99', 'renamed scaffold contig';
is $sort_contigs->_rename_contig('random_contig_name',99), 'random_contig_name.99', 'renamed contig';
ok $sort_contigs->contig_basename('sorted'), 'set contig basename';
is $sort_contigs->_rename_contig('NODE_3_length_14_cov_10.00',99), 'sorted99', 'renamed contig with new contig basename';

# check output name
$sort_contigs = Bio::AssemblyImprovement::Util::OrderContigsByLength->new( input_filename  => 'contigs.signed.queried.lost.found.fa' );
is $sort_contigs->output_filename(), './contigs.signed.queried.lost.found.sorted.fa', 'output file keeps .fa as suffix';
$sort_contigs = Bio::AssemblyImprovement::Util::OrderContigsByLength->new( input_filename  => 'contigs.signed.queried.lost.found.fasta' );
is $sort_contigs->output_filename(), './contigs.signed.queried.lost.found.sorted.fasta', 'output file keeps .fasta as suffix';
$sort_contigs = Bio::AssemblyImprovement::Util::OrderContigsByLength->new( input_filename  => 'contigs.fa.signed.queried.lost.found' );
is $sort_contigs->output_filename(), './contigs.fa.signed.queried.lost.found.sorted', 'output file appends .sorted when suffix not fa';

done_testing();
