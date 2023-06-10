every 1.day, at: '17:00' do
    runner 'AutoPricedownJob.perform_now'
  end
  