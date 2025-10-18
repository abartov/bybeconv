# frozen_string_literal: true

desc "Transition authorities and manifestations to public domain based on copyright expiration (death + 71 years)"
task :copyright_expiration, [:execute] => :environment do |_task, args|
  # Default to dry-run mode unless --execute is passed
  execute_mode = args[:execute] == 'execute'
  
  if execute_mode
    puts "Running in EXECUTE mode - changes will be saved to database"
  else
    puts "Running in DRY-RUN mode - no changes will be saved"
    puts "To execute changes, run: rake copyright_expiration[execute]"
  end
  puts ""
  
  # Calculate the target year (71 years ago from current year)
  current_year = Time.zone.today.year
  target_year = current_year - 71
  
  puts "Processing authorities who died in #{target_year} (#{current_year} - 71 years)..."
  puts ""
  
  # Statistics
  stats = {
    authorities_checked: 0,
    authorities_updated: 0,
    manifestations_checked: 0,
    manifestations_updated: 0
  }
  
  # Find all people who died in the target year and are not yet public domain
  Person.find_each do |person|
    next if person.authority.nil?
    next if person.deathdate.blank?
    
    death_year = person.death_year.to_i
    next if death_year == 0 || death_year != target_year
    
    authority = person.authority
    stats[:authorities_checked] += 1
    
    # Skip if already public domain
    if authority.intellectual_property_public_domain?
      puts "Authority '#{authority.name}' (ID: #{authority.id}) - already public_domain, skipping"
      next
    end
    
    puts "Authority '#{authority.name}' (ID: #{authority.id}) - died in #{death_year}"
    puts "  Current status: #{authority.intellectual_property}"
    puts "  Updating to: public_domain"
    
    if execute_mode
      authority.update!(intellectual_property: :public_domain)
      stats[:authorities_updated] += 1
      puts "  ✓ Updated"
    else
      stats[:authorities_updated] += 1
      puts "  [DRY-RUN] Would update"
    end
    
    # Now check manifestations involving this authority
    manifestations = authority.manifestations
    
    manifestations.each do |manifestation|
      stats[:manifestations_checked] += 1
      
      # Skip if manifestation is not published
      next unless manifestation.published?
      
      # Get all involved authorities for this manifestation
      involved_authorities = manifestation.involved_authorities.map(&:authority).uniq
      
      # Check if all involved authorities are public_domain
      all_public_domain = involved_authorities.all? do |auth|
        # In execute mode, we already updated the current authority, so check it separately
        if execute_mode && auth.id == authority.id
          true # We just updated it
        elsif !execute_mode && auth.id == authority.id
          true # In dry-run, assume this authority would be updated
        else
          auth.intellectual_property_public_domain?
        end
      end
      
      # Only update if all authorities are public_domain
      if all_public_domain
        expression = manifestation.expression
        
        # Check if expression needs updating
        unless expression.intellectual_property_public_domain?
          puts "  Manifestation '#{manifestation.title}' (ID: #{manifestation.id})"
          puts "    Expression (ID: #{expression.id}) current status: #{expression.intellectual_property}"
          puts "    Updating expression to: public_domain"
          
          if execute_mode
            expression.update!(intellectual_property: :public_domain)
            stats[:manifestations_updated] += 1
            puts "    ✓ Updated"
          else
            stats[:manifestations_updated] += 1
            puts "    [DRY-RUN] Would update"
          end
        end
      end
    end
    
    puts ""
  end
  
  # Print summary
  puts "=" * 80
  puts "SUMMARY"
  puts "=" * 80
  puts "Mode: #{execute_mode ? 'EXECUTE' : 'DRY-RUN'}"
  puts "Target year: #{target_year}"
  puts ""
  puts "Authorities:"
  puts "  Checked: #{stats[:authorities_checked]}"
  puts "  #{execute_mode ? 'Updated' : 'Would update'}: #{stats[:authorities_updated]}"
  puts ""
  puts "Manifestations:"
  puts "  Checked: #{stats[:manifestations_checked]}"
  puts "  #{execute_mode ? 'Updated' : 'Would update'}: #{stats[:manifestations_updated]}"
  puts "=" * 80
  
  unless execute_mode
    puts ""
    puts "This was a dry-run. To apply changes, run:"
    puts "  rake copyright_expiration[execute]"
  end
end
