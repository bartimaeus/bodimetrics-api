require 'jwt'
require 'rest-client'

class BodiMetrics
  def initialize
    self.base_url = ENV['BODIMETRICS_API_ENDPOINT']
    get_auth_token
  end

  # Patients: This call will retrieve the information for any patients that you have privileges to view.
  def get_patients
    begin
      data = {
        idsOnly: false, # TRUE to return patient ids only, FALSE to return patient ids and all demographic data
        clientId: ENV['BODIMETRICS_CLIENT_ID']
      }
      response = RestClient.post "#{base_url}/patients", data, {content_type: "application/x-www-form-urlencoded", authorization: "Bearer #{auth_token}"}
      JSON.parse(response.body)
    rescue => e
      puts "failed #{e}"
    end
  end

  # Measurements: This call will retrieve measurements for any or all of your patients.
  #
  # Device              | DeviceId  | Measurements
  # -----------------------------------------------------------
  # Performance Monitor |     1     | bodytemp, duration, ecg, heartrate, hrv, objecttemp, pulse, relax, resp, rpp, sbp, spo2, steps
  #
  # VitalsRx            |     2     | bodytemp, dpb, duration, ecg, ecgholter, heartrate, hrv, lowsat, objecttemp, pulse, rr, sbp, sleepduration,
  #                                   sleepspo2, spo2, spo2avg, spo2drops, spo2lowest, steps, stresstime
  #
  # O2 Vibe             |     3     | sleep, sleep_avghr, sleep_avgspo2, sleep_drops, sleep_duration, sleep_lowspo2, sleep_o2score, sleep_time
  #                                   steps, steps_avghr, steps_avgspo2, steps_goal, steps_lowspo2, steps_rectime, steps_steps
  def get_measurements(patientIds, measurements, device_id = 1, start_date = nil, end_date = nil)
    start_date ||= Date.today
    end_date ||= 1.month.ago
    begin
      data = {
        patientIds: patientIds, # an array of the patient ids retrieved in the step 2. These are the keys from the patients array. Leave array blank for all patients.
        measurements: measurements, # an array of the desired measurements. Leave array blank for all measurements. (see table below for deviceId and associated measurements)
        deviceId: device_id, # YOUR DEVICE TYPE (see table above)
        clientId: ENV['BODIMETRICS_CLIENT_ID'],
        startDate: start_date.strftime("%m-%d-%Y %H:%M:%S"), # MM-DD-YYYY HH:mm:ss
        endDate: end_date.strftime("%m-%d-%Y %H:%M:%S") # MM-DD-YYYY HH:mm:ss
      }
      response = RestClient.post "#{base_url}/measurements", data, {content_type: "application/x-www-form-urlencoded", authorization: "Bearer #{auth_token}"}
      JSON.parse(response.body)
    rescue => e
      puts "failed #{e}"
    end
  end


  # PWI (): This call will retrieve pwi results for any or all of your patients
  def get_pwi(patientIds, start_date = nil, end_date = nil)
    start_date ||= Date.today
    end_date ||= 1.month.ago
    begin
      data = {
        patientIds: patientIds, # an array of the patient ids retrieved in the step 2. These are the keys from the patients array. Leave array blank for all patients.
        clientId: ENV['BODIMETRICS_CLIENT_ID'],
        startDate: start_date.strftime("%m-%d-%Y %H:%M:%S"), # MM-DD-YYYY HH:mm:ss
        endDate: end_date.strftime("%m-%d-%Y %H:%M:%S") # MM-DD-YYYY HH:mm:ss
      }
      response = RestClient.post "#{base_url}/pwi", data, {content_type: "application/x-www-form-urlencoded", authorization: "Bearer #{auth_token}"}
      JSON.parse(response.body)
    rescue => e
      puts "failed #{e}"
    end
  end

  private
  attr_accessor :auth_token, :base_url

  # Sign in to the BodiMetrics API and get the auth token needed for future calls
  def get_auth_token
    payload = {
      "clientId" => ENV['BODIMETRICS_CLIENT_ID'],
      "requestTime" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
    }
    token = JWT.encode payload, ENV['BODIMETRICS_CLIENT_SECRET'], 'HS256'

    begin
      response = RestClient.post "#{base_url}/auth", token, {content_type: "application/x-www-form-urlencoded"}
      json = JSON.parse(response.body)
      if json["success"]
        self.auth_token = json["data"]
      end
    rescue => e
      puts e
    end
  end

end
