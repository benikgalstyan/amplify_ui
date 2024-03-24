import 'dart:convert';
import 'package:flutter/services.dart';

class EnvironmentConfig {
  final String assetsBucketName;
  final String apiUrl;
  final String clientId;
  final String poolId;
  final String identityPoolId;

  EnvironmentConfig({
    required this.assetsBucketName,
    required this.apiUrl,
    required this.clientId,
    required this.poolId,
    required this.identityPoolId,
  });
}

Future<String> getAmplifyConfig() async {
  try {
    final jsonString = await rootBundle.loadString('lib/cognito.json');
    final jsonMap = json.decode(jsonString);
    final config = EnvironmentConfig(
      assetsBucketName: jsonMap['assetsBucketName'],
      apiUrl: jsonMap['apiUrl'],
      clientId: jsonMap['clientId'],
      poolId: jsonMap['poolId'],
      identityPoolId: jsonMap['identityPoolId'],
    );
    return buildAmplifyConfig(config);
  } catch (e) {
    final config = EnvironmentConfig(
      apiUrl: const String.fromEnvironment('API_URL'),
      assetsBucketName: const String.fromEnvironment('ASSETS_BUCKET_NAME'),
      clientId: const String.fromEnvironment('CLIENT_ID'),
      poolId: const String.fromEnvironment('POOL_ID'),
      identityPoolId: const String.fromEnvironment('IDENTITY_POOL_ID'),
    );
    return buildAmplifyConfig(config);
  }
}

String buildAmplifyConfig(EnvironmentConfig config) {
  return """{
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "api": {
      "plugins": {
        "awsAPIPlugin": {
          "private": {
            "endpointType": "GraphQL",
            "endpoint": "${config.apiUrl}",
            "region": "us-east-1",
            "authorizationType": "AMAZON_COGNITO_USER_POOLS"
          },
          "public": {
            "endpointType": "GraphQL",
            "endpoint": "${config.apiUrl}",
            "region": "us-east-1",
            "authorizationType": "AWS_IAM"
          }
        }
      }
    },
    "storage": {
      "plugins": {
        "awsS3StoragePlugin": {
          "bucket": "${config.assetsBucketName}",
          "region": "us-east-1"
        }
      }
    },
    "auth": {
      "plugins": {
        "awsCognitoAuthPlugin": {
          "UserAgent": "aws-amplify-cli/0.1.0",
          "Version": "0.1.0",
          "IdentityManager": {
            "Default": {}
          },
          "CredentialsProvider": {
            "CognitoIdentity": {
              "Default": {
                "PoolId": "${config.identityPoolId}",
                "Region": "us-east-1"
              }
            }
          },
          "CognitoUserPool": {
            "Default": {
              "PoolId": "${config.poolId}",
              "AppClientId": "${config.clientId}",
              "Region": "us-east-1"
            }
          },
          "Auth": {
            "Default": {
              "authenticationFlowType": "USER_PASSWORD_AUTH",
              "socialProviders": [],
              "usernameAttributes": [
                
              ],
              "signupAttributes": [
                "BIRTHDATE",
                "EMAIL",
                "FAMILY_NAME",
                "NAME",
                "NICKNAME",
                "PREFERRED_USERNAME",
                "WEBSITE",
                "ZONEINFO"
              ],
              "passwordProtectionSettings": {
                "passwordPolicyMinLength": 8,
                "passwordPolicyCharacters": []
              },
              "mfaConfiguration": "OFF",
              "mfaTypes": [
                "SMS"
              ],
              "verificationMechanisms": [
                "EMAIL"
              ]
            }
          }
        }
      }
    }
  }""";
}
