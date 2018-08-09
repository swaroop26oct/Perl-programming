#!/usr/local/bin/perl
use strict;
use warnings;

# File Name: prog2.pl
# Name: Nagaswaroop Kengunte Nagaraj
# Date: 15 october 2016


#Error message if there is no command line argument
my($USAGE)= "$0 Complier did not find an argument.\n Please add an argument.\n\n";

#Check if there are any command line argument else print $USAGE message
unless(@ARGV)
{
	print $USAGE;
	exit;
}

#Initialise command line arguments to its respective variables
my $fileread=$ARGV[0];

#calling read_fasta subroutine and expecting @header,@sequence and @count_total_number_of_sequences as returns from the subroutine
my($header_ref,$sequence_ref,$count_ref)=read_fasta($fileread);
#dereferencing the returned values from read_fasta subroutine
my @header= @$header_ref;
my @sequence= @$sequence_ref;
my $count=$$count_ref;


#Filename to write un permuted output
my$filename="genes.ot"; 
#Calling the stat_fasta subroutine and expecting @acount,@ccount,@gcount,@tcount,@aprops,@cprops,@gprops,@tprops,@cgcount,@cgprops as return values from the subroutine
my($acount_ref,$ccount_ref,$gcount_ref,$tcount_ref,$aprops_ref,$cprops_ref,$gprops_ref,$tprops_ref,$cgcount_ref,$cgprops_ref)=stat_fasta(\@header,\@sequence,\$count,\$filename);
my(@acount,@ccount,@gcount,@tcount,@aprops,@cprops,@gprops,@tprops,@cgcount,@cgprops)=($acount_ref,$ccount_ref,$gcount_ref,$tcount_ref,$aprops_ref,$cprops_ref,$gprops_ref,$tprops_ref,$cgcount_ref,$cgprops_ref);
print "Output for the file $fileread is generated in the file $filename\n";

#Calling the permute_fasta subroutine to do some permutation in each string and expecting a new permuted sequence as a returned value
my $permute_seq= permute_fasta(\@sequence,\$count);
my @permute_sequence= @$permute_seq;


#Output file name to write the new permuted_fasta file
my $new_file="genes_permute.fsa"; 
#Calling write_fasta subroutine to write to the new output file by passing the new permuted sequence and a corresponding header
write_fasta(\@header,\@permute_sequence,\$new_file,\$count);
print "Output for the permuted file $new_file is generated in the file $new_file\n";

#Calling read_fasta to obtain the new header and sequence information by passing the permuted file
($header_ref,$sequence_ref,$count_ref)=read_fasta($new_file);
@header= @$header_ref;
@sequence= @$sequence_ref;
$count=$$count_ref;


#Calling the stat_fasta for this newly permuted file and writing the results to a new output file
my $permute_file="genes_permute.ot";
($acount_ref,$ccount_ref,$gcount_ref,$tcount_ref,$aprops_ref,$cprops_ref,$gprops_ref,$tprops_ref,$cgcount_ref,$cgprops_ref)=stat_fasta(\@header,\@sequence,\$count,\$permute_file);
print "Output for the file $new_file is generated in the file $permute_file\n";

print("Done\n");
exit;


###########################################################################################################################################################################################
#START OF THE SUBROUTINES CALLED BY THE MAIN PROGRAM

#Subroutine to differentiate the header and sequence for the file sent in as input and returning them back to the main program
sub read_fasta
{
	my($fileread)=@_;
#Checking if the file exists or no, if the file is not found then print an error message
	open(FILEREAD,$fileread) or die "File $fileread does not exist.\nPlease enter the correct file name.\n,$!";

#Storing the contents of FILEREAD
	my @content=<FILEREAD>;
	chomp @content;
	close FILEREAD;	
#Initialise the variables
	my@header=();
	my@sequence=();
	my$count=0;
	my$n=-1;

#Check for each line of the sequence if its a header or a sequence and update the number of header and sequences found.
	foreach my$line (@content)
	{
		chomp $line;
		if ($line =~ /^>/) 
		{
			$n++;         
			$header[$n] = $line; 
			$sequence[$n] = "";  
			$count=$count+1;
		}
		else 
		{
		next if not @header; 
		$sequence[$n] .= $line;
		}
	}

#Remove all whitespaces
	for (my $i = 0; $i < $count; $i++)
	{
		$sequence[$i] =~ s/\s//g;
	}
	
	return (\@header,\@sequence,\$count);
}




#Subroutine which gives all the details about each sequence in a file and also writes the output to the filename given by the user
sub stat_fasta	
{
	my ($header,$sequence,$count,$filename)=@_;

#Opening a file in write format
	open(FILEWRITE, '>', $$filename) or die "Cannot open '$$filename',$!";
	
	print FILEWRITE "\nReport of the file $$filename \n";
	print FILEWRITE "\nNumber of sequences:$$count\n";    
	
	my $combine= join('',@$sequence);   #Converting the array into a string              
	my$total=length $combine;           #Finding the length
	print FILEWRITE "Total length of all sequences together is:$total\n";

#Calculating Maximum and minimum length, avg of the sequences
	my $big=0;
	for (my $i=0; $i<$$count;$i++)
	{
		if ($big > length @$sequence[$i])
			{
				$big=$big;
			}
		else
			{
				$big=length @$sequence[$i];
			}
	}
	print FILEWRITE "Maximum sequence length is: $big\n";

	my $small=$big;
	for (my $i=0; $i<$$count;$i++)
	{

	if ($small < length @$sequence[$i])
			{
				$small=$small;
			}
		else
			{
				$small=length @$sequence[$i];
			}
	}
	print FILEWRITE "Minimum sequence length is: $small\n";
	
	my $average= $total/$$count;
	print FILEWRITE "Average length of the sequences is:$average\n";

#Calculating the A,C,G,T and CG counts and proportions	
	for (my $i = 0; $i < $$count; $i++)
	{
		print FILEWRITE "\n@$header[$i]\n";						   #Printing each header followed by its details
		print FILEWRITE "Length: ",length @$sequence[$i],"\n";     #Printing length of each sequence  
		my $dna=@$sequence[$i];	
		my $total_length_DNA= length $dna;
#Initialising each base to zero
		my($count_A)=0;
		my($count_T)=0;
		my($count_C)=0;
		my($count_G)=0;	

#Initialising array's in order to use them to send them back as references to the main program		
		my @acount=();
		my @aprops=();
		my @ccount=();
		my @cprops=();
		my @gcount=();
		my @gprops=();
		my @tcount=();
		my @tprops=();
		my @cgcount=();
		my @cgprops=();
		
#Counting the number of nucleotides respectively present in the DNA
		$count_A=($dna =~ tr/Aa//);
		my$frac_A= $count_A/$total_length_DNA;
		$acount[$i]=$count_A;
		$aprops[$i]=$frac_A;
	
		$count_C=($dna =~ tr/Cc//);
		my$frac_C= $count_C/$total_length_DNA;
		$ccount[$i]=$count_C;
		$cprops[$i]=$frac_C;

		
		$count_G=($dna =~ tr/Gg//);
		my$frac_G= $count_G/$total_length_DNA;
		$gcount[$i]=$count_G;
		$gprops[$i]=$frac_G;
		
		$count_T=($dna =~ tr/Tt//);
		my$frac_T= $count_T/$total_length_DNA;
		$tcount[$i]=$count_T;
		$tprops[$i]=$frac_T;
		
	
#Finding the CpG sequence in a string
		my$CG=0;
		while ($dna =~ /(CG)/ig)             #Matching the CG's (Case sensitive) in the string $dna
		{
			$CG++;
		}
#Calculating the fraction of CpG
		my $frac_CG= $CG/$total_length_DNA;
		$cgcount[$i]=$CG;
		$cgprops[$i]=$frac_CG;
		
#Printing count of the nucleotides, using printf to print the fractions upto only 2 decimal spaces
		print FILEWRITE "A:$acount[$i]"; printf FILEWRITE " %0.2f",$aprops[$i],"\n";
		print FILEWRITE "\nC:$ccount[$i]"; printf FILEWRITE " %0.2f",$cprops[$i],"\n";
		print FILEWRITE "\nG:$gcount[$i]"; printf FILEWRITE " %0.2f",$gprops[$i],"\n";
		print FILEWRITE "\nT:$tcount[$i]"; printf FILEWRITE " %0.2f",$tprops[$i],"\n";
		print FILEWRITE "\nCpG:$cgcount[$i]";printf FILEWRITE " %0.2f",$cgprops[$i],"\n\n";
	}
	close FILEWRITE;
#Returning the references to A,C,G,T and CG counts and proportions back to the main program
	return (\@acount,\@ccount,\@gcount,\@tcount,\@aprops,\@cprops,\@gprops,\@tprops,\@cgcount,\@cgprops);
}


#Subroutine to randomly permute a given sequence and pass that sequence as a new permuted sequence back to the main program
sub permute_fasta
{
	my($sequence,$count)=@_;
	my$dna;
	my$new_base;
	my @permute_sequence=();
	
	for(my $i=0;$i<$$count;$i++)
	{
		$dna=@$sequence[$i];
		
#Seeding the srand function 
		srand(time|$$);
		
		my$flag=0;											#Initializing a variable to keep a count

#Randomly Permute the sequence till the count is less than the length of the sequence that is being passed for permutation
		while($flag<length($dna))
		{
			my $random_position_1= int(rand(length($dna))); 		#Obtaining a position randomly 
			my $random_position_2= int(rand(length($dna)));			#Obtaining another position randomly

			my $random_base_1=substr($dna,$random_position_1,1);	#Storing the Base at position_1 in a variable
			my $random_base_2=substr($dna,$random_position_2,1);	#Storing the Base at position_2 in a variable
			
#Checking if the bases are same if not same then swap the two bases from their respective positions
			if($random_base_1 ne $random_base_2)					
			{
				substr($dna,$random_position_1,1,$random_base_2);
				substr($dna,$random_position_2,1,$random_base_1);
				$flag++;
			}
		}
		push(@permute_sequence,$dna);
	}
	return (\@permute_sequence);									#Returing the permuted sequence back to the main program
}

#Subroutine to accept header and sequence and write them to an output file provided by the User
sub write_fasta
{
	my($header,$permute_sequence,$new_file,$count)=@_;
#Creating a hash to write the header and its corresponding sequence just like a pair of key and value
	my %write;
	@write{@$header}=@$permute_sequence;
	
	open(PERMUTEFILE, '>', $$new_file) or die "Cannot open '$$new_file',$!";
	
#Sorting the hash with respect to alphabetical order of headers
	foreach my$head (sort(keys %write))
	{
		print PERMUTEFILE "$head\n";
		print PERMUTEFILE "$write{$head}\n";
	}
	close PERMUTEFILE;
}