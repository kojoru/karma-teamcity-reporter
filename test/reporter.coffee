chai = require 'chai'
should = chai.should()
sinon = require 'sinon'
sinonaChai = require 'sinon-chai'

chai.use(sinonaChai)

TeamCityReporter = require('./../index')['reporter:teamcity'][1]

describe 'TeamCity reporter', ->
  reporter = null
  mosaic = {id: 'id', name: 'Mosaic'}

  beforeEach (done) ->
    reporter = new TeamCityReporter (instance) ->
      instance.write = sinon.spy()
    done()

  it 'should not produce messages without browsers', (done) ->
    reporter.onRunStart []
    reporter.onRunComplete []
    reporter.write.should.not.been.called
    done()

  it 'should produce messages without tests', (done) ->
    reporter.onRunStart [mosaic]
    reporter.onRunComplete []
    reporter.write.should.have.been.calledWith '##teamcity[browserStart name=\'Mosaic\']\n'
    reporter.write.should.have.been.calledWith '##teamcity[browserEnd name=\'Mosaic\']\n'
    done()

  it 'should produce messages with one test', (done) ->
    reporter.onRunStart [mosaic]
    reporter.specSuccess mosaic, {description: 'SampleTest', time: 2, suite: ['Suite 1']}
    reporter.onRunComplete []
    reporter.write.should.have.been.calledWith('##teamcity[browserStart name=\'Mosaic\']\n')
    reporter.write.should.have.been.calledWith('##teamcity[browserEnd name=\'Mosaic\']\n')
    reporter.write.should.have.been.calledWith """
      ##teamcity[testSuiteStarted name=\'Suite 1\']
      ##teamcity[testStarted name=\'SampleTest\']
      ##teamcity[testFinished name=\'SampleTest\' duration=\'2\']
      ##teamcity[testSuiteFinished name=\'Suite 1\']

    """
    done()

