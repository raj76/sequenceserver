require 'uri'

module SequenceServer
  module Customisation
    ## When not commented out, this method is used to take a
    ## sequence ID, and return a hyperlink that
    ## replaces the hit in the BLAST output.
    ##
    ## Return the hyperlink to link to, or nil
    ## to not not include a hyperlink.
    ##
    ## When this method
    ## is commented out, the default link is used. The default
    ## is a link to the full sequence of
    ## the hit is displayed (if makeblastdb has been run with
    ## -parse_seqids), or no link at all otherwise.
     def construct_custom_sequence_hyperlink(options)
       ## Example:
       ## sequence_id comes in like "psu|MAL13P1.200 | organism=Plasmodium_falciparum_3D7 | product=mitochondrial"
       ## output: "http://apiloc.bio21.unimelb.edu.au/apiloc/gene/MAL13P1.200"
       matches = options[:sequence_id].match(/^\s*lcl\|(\S+) /)
       if matches #if the sequence_id conforms to our expectations
         # All is good. Return the hyperlink.
         from = options[:hit_coordinates][0] - 5000
         to = options[:hit_coordinates][1] + 5000
         if(from < 1)
           from = 1
         end
         seqName = matches[1]
         geneModelMatch = seqName.match(/evm_27\.model\.(\S+)/)
         if geneModelMatch
           return "http://amborella.uga.edu/mgb2/gbrowse/amborella_amtr_v_0_10/?name=EVM_27 prediction #{geneModelMatch[1]}"
         else
           return "http://asparagus.uga.edu/jbrowse/?loc=#{matches[1]}:#{from}..#{to}"
         end
       else
         matches = options[:sequence_id].match(/^\s*gnl\|(\S+?)\|(\S+).*/)
         if matches #if the sequence_id conforms to our expectations
           seq_name = URI.escape("gnl|#{matches[1]}|#{matches[2]}", Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
           cust_link = ""
           db_name = matches[1]
           case db_name
           when "Amborella"
             cust_link = "http://jlmwiki.plantbio.uga.edu/aagp/?name=#{seq_name}&taxaId=1&assemblyId=1"
           when "Ambo_Trinity"
             cust_link = "http://jlmwiki.plantbio.uga.edu/aagp/?name=#{seq_name}&taxaId=1&assemblyId=7"
           else
             cust_link = "Hello!!!"
           end
           return cust_link
         else
           # Parsing the sequence_id didn't work. Don't include a hyperlink for this
           # sequence_id, but log that there has been a problem.
           settings.log.warn "Unable to parse sequence id `#{options[:sequence_id]}'"
           # Return nil so no hyperlink is generated.
           return "No link" ##construct_standard_sequence_hyperlink(options)
         end
       end
     end

    ## Much like construct_custom_sequence_hyperlink, except
    ## instead of just a hyperlink being defined, the whole
    ## line as it appears in the blast results is generated.
    ##
    ## This is a therefore more flexible setup than is possible
    ## with construct_custom_sequence_hyperlink, because doing
    ## things such as adding two hyperlinks for the one hit
    ## are possible.
    ##
    ## When this method is commented out, the behaviour is that
    ## the construct_custom_sequence_hyperlink method is used,
    ## or failing that the default method of that is used.
     def construct_custom_sequence_hyperlinking_line(options)
       link1 = construct_custom_sequence_hyperlink(options)
       link2 = construct_standard_sequence_hyperlink(options)
       if link1.eql?("No link")
         return "><a href='#{url(link2)}' target='_blank'>#{options[:sequence_id]}</a> \n"
       else
         return "><a href='#{url(link1)}' target='_blank'>#{options[:sequence_id]}</a>&nbsp;<a href='#{url(link2)}' target='_blank'>Download #{options[:sequence_id]}</a> \n"
       end

     end
  end
end
