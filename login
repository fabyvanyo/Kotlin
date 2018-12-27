package updateme.updateme.live.updateme.Controller

import android.content.Context
import android.content.DialogInterface
import android.content.Intent
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.support.v7.app.AlertDialog
import android.text.method.HideReturnsTransformationMethod
import android.text.method.PasswordTransformationMethod
import android.util.Patterns
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.Toast
import kotlinx.android.synthetic.main.activity_login.*
import updateme.updateme.live.updateme.R
import updateme.updateme.live.updateme.Services.AuthService
import updateme.updateme.live.updateme.Services.UserDataService
import java.util.regex.Pattern

class LoginActivity : AppCompatActivity() {

    private val PASSWORD_PATTERN = Pattern.compile("^" +
            //"(?=.*[0-9])" +         //at least 1 digit
            //"(?=.*[a-z])" +         //at least 1 lower case letter
            //"(?=.*[A-Z])" +         //at least 1 upper case letter
            "(?=.*[a-zA-Z])" +      //any letter
            //"(?=.*[@#$%^&+=])" +    //at least 1 special character
            "(?=\\S+$)" +           //no white spaces
            ".{6,}" +               //at least 6 characters
            "$")

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        loginSpinner.visibility = View.INVISIBLE
    }

    fun loginShowHidePwClicked(view: View) {
        if (loginPasswordTxt.text.isNotEmpty()) {
            if (loginShowHidePwBtn.text.toString().equals("Show")) {
                loginPasswordTxt.transformationMethod = HideReturnsTransformationMethod.getInstance()
                loginShowHidePwBtn.text = "Hide"
            } else {
                loginPasswordTxt.transformationMethod = PasswordTransformationMethod.getInstance()
                loginShowHidePwBtn.text = "Show"
            }
        } else {
            loginShowHidePwBtn.text = "Show"
            Toast.makeText(this, "Please fill in password", Toast.LENGTH_SHORT).show()
        }

    }

    fun loginLoginBtnClicked(view: View) {

        enableSpinner(true)

        val email = loginEmailTxt.text.toString()
        val password = loginPasswordTxt.text.toString()

        hideKeyboard()

        if (isEmailValid() && isPasswordValid()) {
            enableSpinner(true)

            AuthService.loginUser(this, email, password) { loginSuccess ->
                if (loginSuccess) {

                    UserDataService.userEmail = email

                    AuthService.getUserInfo(this) { userInfoSuccess ->
                        if (userInfoSuccess) {
                            enableSpinner(false)
                            finish()
                        } else {
                            errorToast()
                        }
                    }

                } else {
                    errorToast()
                }
            }

        } else {
            enableSpinner(false)
        }


    }

    fun loginRegisterBtnClicked(view: View) {
        val registerIntent = Intent(this, RegisterUserActivity::class.java)
        startActivity(registerIntent)
        finish()
    }

    fun forgotPasswordClicked(view: View) {
        loginEmailTxt.text.clear()
        loginPasswordTxt.text.clear()

        val builder = AlertDialog.Builder(this)
        val dialogView = layoutInflater.inflate(R.layout.forgot_password_dialog, null)

        builder.setView(dialogView)
                .setPositiveButton("Send", null)
                .setNegativeButton("Cancel", null)

        val alertDialog = builder.create()
        alertDialog.show()

        val positiveButton = alertDialog.getButton(DialogInterface.BUTTON_POSITIVE)

        positiveButton.setOnClickListener {
            val emailFieldTxt = dialogView.findViewById<EditText>(R.id.forgotPasswordEmailTxt)
            val emailTxt = emailFieldTxt.text.toString()

            if (emailTxt.isNotEmpty()) {
                // println("faby's email ${emailTxt}")
                alertDialog.dismiss()
            } else {
                Toast.makeText(this, "Please enter your email.", Toast.LENGTH_SHORT).show()
            }
        }

    }

    private fun isEmailValid(): Boolean {

        val emailInput = loginEmailTxt.text.toString().trim()

        if (emailInput.isEmpty()) {
            loginEmailTxt.error = "Field can't be empty";
            return false
        } else if (!Patterns.EMAIL_ADDRESS.matcher(emailInput).matches()) {
            loginEmailTxt.error = "Please enter a valid email address";
            return false;
        } else {
            loginEmailTxt.error = null
            return true
        }
    }

    private fun isPasswordValid(): Boolean {

        val passwordInput = loginPasswordTxt.text.toString().trim()

        if (passwordInput.isEmpty()) {
            loginPasswordTxt.error = "Field can't be empty"
            return false
        } else if (!PASSWORD_PATTERN.matcher(passwordInput).matches()) {
            loginPasswordTxt.error = "Password too weak"
            return false
        } else {
            loginPasswordTxt.error = null
            return true
        }
    }

    private fun isPasswordValid(password: String): Boolean {

        return password.length > 4
    }

    override fun onBackPressed() {
        //super.onBackPressed()
    }

    fun errorToast() {
        Toast.makeText(this, "Something went wrong, please try again.", Toast.LENGTH_LONG).show()
        enableSpinner(false)
    }

    fun enableSpinner(enable: Boolean) {
        if (enable) {
            loginSpinner.visibility = View.VISIBLE
        } else {
            loginSpinner.visibility = View.INVISIBLE
        }
        loginLoginBtn.isEnabled = !enable
        loginRegisterBtn.isEnabled = !enable
    }

    fun hideKeyboard() {
        val inputManager = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager

        if (inputManager.isAcceptingText) {
            inputManager.hideSoftInputFromWindow(currentFocus.windowToken, 0)
        }
    }
}
