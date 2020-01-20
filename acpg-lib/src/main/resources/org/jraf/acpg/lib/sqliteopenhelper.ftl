<#if header??>
${header}
</#if>
package ${config.providerJavaPackage};

// @formatter:off
import android.annotation.TargetApi;
import android.content.Context;
import net.sqlcipher.DatabaseErrorHandler;
import net.sqlcipher.DefaultDatabaseErrorHandler;
import net.sqlcipher.database.SQLiteDatabase;
import net.sqlcipher.database.SQLiteOpenHelper;
import android.os.Build;
import android.util.Log;

import ${config.providerJavaPackage}.base.BaseSQLiteOpenHelperCallbacks;
<#if (config.sqliteOpenHelperCallbacksClassName)??>
import ${config.providerJavaPackage}.${config.sqliteOpenHelperCallbacksClassName};
</#if>
import ${config.packageName}.BuildConfig;
<#list model.entities as entity>
import ${config.providerJavaPackage}.${entity.packageName}.${entity.nameCamelCase}Columns;
</#list>

public class ${config.sqliteOpenHelperClassName} extends SQLiteOpenHelper {
    private static final String TAG = ${config.sqliteOpenHelperClassName}.class.getSimpleName();

    public static String sDATABASE_FILE_NAME = "${config.databaseFileName}";
    private static final int DATABASE_VERSION = ${config.databaseVersion};
    private static ${config.sqliteOpenHelperClassName} sInstance;
    private final Context mContext;
    private final BaseSQLiteOpenHelperCallbacks mOpenHelperCallbacks;

    <#list model.entities as entity>
    public static final String SQL_CREATE_TABLE_${entity.nameUpperCase} = "CREATE TABLE IF NOT EXISTS "
            + ${entity.nameCamelCase}Columns.TABLE_NAME + " ( "
            <#list entity.fields as field>
                <#if field.isId>
            + ${entity.nameCamelCase}Columns._ID + " INTEGER PRIMARY KEY<#if field.isAutoIncrement> AUTOINCREMENT</#if>, "
                <#else>
            + ${entity.nameCamelCase}Columns.${field.nameUpperCase} + " ${field.type.sqlType}<#if !field.isNullable> NOT NULL</#if><#if field.hasDefaultValue> DEFAULT ${field.defaultValue}</#if><#if field_has_next>,</#if> "
                </#if>
            </#list>
            <#if config.enableForeignKeys >
                <#list entity.fields as field>
                    <#if field.foreignKey??>
            + ", CONSTRAINT fk_${field.nameLowerCase} FOREIGN KEY (" + ${entity.nameCamelCase}Columns.${field.nameUpperCase} + ") REFERENCES ${field.foreignKey.entity.nameLowerCase} (${field.foreignKey.field.nameLowerCase}) ON DELETE ${field.foreignKey.onDeleteAction.toSql()}"
                    </#if>
                </#list>
            </#if>
            <#list entity.constraints as constraint>
            + ", CONSTRAINT ${constraint.name} ${constraint.definition}"
            </#list>
            + " );";

    <#list entity.fields as field>
    <#if field.isIndex>
    public static final String SQL_CREATE_INDEX_${entity.nameUpperCase}_${field.nameUpperCase} = "CREATE INDEX IDX_${entity.nameUpperCase}_${field.nameUpperCase} "
            + " ON " + ${entity.nameCamelCase}Columns.TABLE_NAME + " ( " + ${entity.nameCamelCase}Columns.${field.nameUpperCase} + " );";

    </#if>
    </#list>
    </#list>

    public static ${config.sqliteOpenHelperClassName} getInstance(Context context) {
        // Use the application context, which will ensure that you
        // don't accidentally leak an Activity's context.
        // See this article for more information: http://bit.ly/6LRzfx
        if (sInstance == null) {
            sInstance = newInstance(context.getApplicationContext());
        }
        return sInstance;
    }

    private static ${config.sqliteOpenHelperClassName} newInstance(Context context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.HONEYCOMB) {
            return newInstancePreHoneycomb(context);
        }
        return newInstancePostHoneycomb(context);
    }


    /*
     * Pre Honeycomb.
     */
    private static ${config.sqliteOpenHelperClassName} newInstancePreHoneycomb(Context context) {
        return new ${config.sqliteOpenHelperClassName}(context);
    }

    private ${config.sqliteOpenHelperClassName}(Context context) {
        super(context, ${config.sqliteOpenHelperCallbacksClassName}.getSavedDbName(context, sDATABASE_FILE_NAME), null, DATABASE_VERSION);
        mContext = context;
        resetDBName(${config.sqliteOpenHelperCallbacksClassName}.getSavedDbName(context, sDATABASE_FILE_NAME));
        //https://www.zetetic.net/sqlcipher/sqlcipher-for-android/
        //The call to SQLiteDatabase.loadLibs(this) must occur before any other database operation. The following is a usage example in Java
        SQLiteDatabase.loadLibs(ctx);
        <#if (config.sqliteOpenHelperCallbacksClassName)??>
        mOpenHelperCallbacks = new ${config.sqliteOpenHelperCallbacksClassName}();
        <#else>
        mOpenHelperCallbacks = new BaseSQLiteOpenHelperCallbacks();
        </#if>
    }


    /*
     * Post Honeycomb.
     */
    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    private static ${config.sqliteOpenHelperClassName} newInstancePostHoneycomb(Context context) {
        return new ${config.sqliteOpenHelperClassName}(context, new DefaultDatabaseErrorHandler());
    }

    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    private ${config.sqliteOpenHelperClassName}(Context context, DatabaseErrorHandler errorHandler) {
        super(context, ${config.sqliteOpenHelperCallbacksClassName}.getSavedDbName(context, sDATABASE_FILE_NAME), null, DATABASE_VERSION, null);
        mContext = context;
        resetDBName(${config.sqliteOpenHelperCallbacksClassName}.getSavedDbName(context, sDATABASE_FILE_NAME));
        //https://www.zetetic.net/sqlcipher/sqlcipher-for-android/
        //The call to SQLiteDatabase.loadLibs(this) must occur before any other database operation. The following is a usage example in Java
        SQLiteDatabase.loadLibs(ctx);
        <#if (config.sqliteOpenHelperCallbacksClassName)??>
        mOpenHelperCallbacks = new ${config.sqliteOpenHelperCallbacksClassName}();
        <#else>
        mOpenHelperCallbacks = new BaseSQLiteOpenHelperCallbacks();
        </#if>
    }

    /*
    * reset name of bdd to open (bdd will be opened on call to getInstance() if instance has been reset
    * @see resetInstance()
    */

    public static void resetDBName(String fileName){
        if(fileName != null)
            sDATABASE_FILE_NAME = fileName;
    }

    public static String getDBName(){
        return sDATABASE_FILE_NAME;
    }

    /*
     * Close connection and reset instance value
     */
    public static void resetInstance(){
        if(sInstance != null)
            sInstance.close();

        sInstance = null;
    }


    @Override
    public void onCreate(SQLiteDatabase db) {
        if (BuildConfig.${config.debugLogsFieldName}) Log.d(TAG, "onCreate");
        mOpenHelperCallbacks.onPreCreate(mContext, db);
        <#list model.entities as entity>
        db.execSQL(SQL_CREATE_TABLE_${entity.nameUpperCase});
        <#list entity.fields as field>
        <#if field.isIndex>
        db.execSQL(SQL_CREATE_INDEX_${entity.nameUpperCase}_${field.nameUpperCase});
        </#if>
        </#list>
        </#list>
        mOpenHelperCallbacks.onPostCreate(mContext, db);
    }

    @Override
    public void onOpen(SQLiteDatabase db) {
        super.onOpen(db);
        <#if config.enableForeignKeys >
        if (!db.isReadOnly()) {
            setForeignKeyConstraintsEnabled(db);
        }
        </#if>
        // https://discuss.zetetic.net/t/what-is-the-purpose-of-pragma-cipher-memory-security/3953/4
        db.rawExecSQL("PRAGMA cipher_memory_security = OFF");
        mOpenHelperCallbacks.onOpen(mContext, db);
    }

    <#if config.enableForeignKeys >
    private void setForeignKeyConstraintsEnabled(SQLiteDatabase db) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN) {
            setForeignKeyConstraintsEnabledPreJellyBean(db);
        } else {
            setForeignKeyConstraintsEnabledPostJellyBean(db);
        }
    }

    private void setForeignKeyConstraintsEnabledPreJellyBean(SQLiteDatabase db) {
        db.execSQL("PRAGMA foreign_keys=ON;");
    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    private void setForeignKeyConstraintsEnabledPostJellyBean(SQLiteDatabase db) {
        db.setForeignKeyConstraintsEnabled(true);
    }

    </#if>
    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        mOpenHelperCallbacks.onUpgrade(mContext, db, oldVersion, newVersion);
    }
}
